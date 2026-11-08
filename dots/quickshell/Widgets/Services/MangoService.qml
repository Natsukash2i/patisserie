pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root

    // outputName -> { tags: [{id,state,clients,focused,urgent}], occupiedMask, selectedMask, urgentMask }
    property var monitors: ({})

    signal tagsChanged(string monitor)

    function viewTag(monitorName, tagId) {
        _run(["mmsg", "dispatch", "viewcrossmon," + tagId + "," + monitorName]);
    }

    function viewNext(monitorName, occupiedOnly) { _stepTag(monitorName, 1, occupiedOnly); }
    function viewPrev(monitorName, occupiedOnly) { _stepTag(monitorName, -1, occupiedOnly); }

    function _stepTag(monitorName, dir, occupiedOnly) {
        const m = monitors[monitorName];
        if (!m || !m.tags.length) return;
        const n = m.tags.length;
        let cur = 0;
        for (let i = 0; i < n; i++) {
            if (m.tags[i].focused) { cur = i; break; }
        }
        for (let step = 1; step <= n; step++) {
            const idx = ((cur + dir * step) % n + n) % n;
            if (!occupiedOnly || m.tags[idx].clients > 0) {
                viewTag(monitorName, m.tags[idx].id);
                return;
            }
        }
        const idx = ((cur + dir) % n + n) % n;
        viewTag(monitorName, m.tags[idx].id);
    }

    function _run(cmdList) {
        dispatchProcComponent.createObject(root, { command: cmdList });
    }

    Component {
        id: dispatchProcComponent
        Process {
            running: true
            onExited: destroy()
        }
    }

    function _mergeSnapshot(json) {
        try {
            const data = JSON.parse(json);
            
            // Handle the nested "all_tags" array structure shown in your logs
            if (data.all_tags && Array.isArray(data.all_tags)) {
                for (let i = 0; i < data.all_tags.length; i++) {
                    const monData = data.all_tags[i];
                    _applyMonitor(monData.monitor, monData.tags);
                }
            } else {
                // Fallback just in case it ever sends a flat object
                for (const monName in data) {
                    _applyMonitor(monName, data[monName]);
                }
            }
        } catch (e) {
            console.warn("MangoService: could not parse tag JSON:", e, json);
        }
    }

    function _applyMonitor(monName, raw) {
        if (!Array.isArray(raw)) return;
        
        let occ = 0, sel = 0, urg = 0;
        
        const tags = raw.map(function (t, i) {
            // Map the new JSON keys to the internal state variables
            const id = (t.index !== undefined) ? t.index : (i + 1);
            const clients = (t.client_count !== undefined) ? t.client_count : 0;
            const focused = (t.is_active !== undefined) ? t.is_active : false;
            const urgent = (t.is_urgent !== undefined) ? t.is_urgent : false;
            
            const state = urgent ? 2 : (focused ? 1 : 0);

            const bit = 1 << (id - 1);
            if (clients > 0) occ |= bit;
            if (focused) sel |= bit;
            if (urgent) urg |= bit;
            
            return { 
                id: id, 
                state: state, 
                clients: clients, 
                focused: focused, 
                urgent: urgent 
            };
        });

        const next = {};
        for (const k in monitors) next[k] = monitors[k];
        next[monName] = { tags: tags, occupiedMask: occ, selectedMask: sel, urgentMask: urg };
        monitors = next;
        
        // Notify Workspaces.qml that this specific monitor has new data
        tagsChanged(monName);
    }

    Process {
        running: true
        command: ["mmsg", "get", "all-tags"]
        stdout: StdioCollector {
            onStreamFinished: root._mergeSnapshot(text)
        }
    }

    Process {
        running: true
        command: ["mmsg", "watch", "all-tags"]
        stdout: SplitParser {
            onRead: line => {
                if (line.trim().length > 0) root._mergeSnapshot(line);
            }
        }
    }
}
