// Model Library - a small macOS app that lists every AI model downloaded on this Mac.
// Build: tools/ModelLibrary/build.sh  ->  ~/Desktop/Model Library.app
// Scans: ComfyUI models folder (+ any folders you add), Hugging Face hub cache, Ollama,
// LM Studio, Torch hub checkpoints. No network, no dependencies.

import SwiftUI
import AppKit

// MARK: - Model

struct ModelEntry: Identifiable, Hashable {
    let id: String            // path
    let name: String
    let source: String        // sidebar group
    let category: String      // e.g. diffusion_models / loras / hf-cache / ollama
    let sizeBytes: Int64
    let modified: Date
    let path: String

    var sizeText: String { ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file) }
}

let modelExtensions: Set<String> = ["safetensors", "ckpt", "pt", "pth", "bin", "gguf", "onnx", "pkl", "msgpack", "h5", "tflite", "mlmodel", "npz"]
let bundleDirExtensions: Set<String> = ["mlmodelc", "mlpackage"]
let minFileBytes: Int64 = 1_000_000

// MARK: - Scanner

enum Scanner {
    static let fm = FileManager.default
    static var home: String { NSHomeDirectory() }

    static func scanAll(extraFolders: [String]) -> [ModelEntry] {
        var out: [ModelEntry] = []
        for folder in extraFolders { out += scanFolder(folder, source: folderLabel(folder)) }
        out += scanHuggingFace()
        out += scanOllama()
        out += scanFolder(home + "/.lmstudio/models", source: "LM Studio")
        out += scanFolder(home + "/.cache/lm-studio/models", source: "LM Studio")
        out += scanFolder(home + "/.cache/torch/hub/checkpoints", source: "Torch hub", flat: true)
        var seen = Set<String>()
        return out.filter { seen.insert($0.id).inserted }
    }

    static func folderLabel(_ folder: String) -> String {
        let url = URL(fileURLWithPath: folder)
        if url.lastPathComponent == "models" { return url.deletingLastPathComponent().lastPathComponent }
        return url.lastPathComponent
    }

    /// Recursive scan of a folder tree. Category = first path component under the root.
    static func scanFolder(_ root: String, source: String, flat: Bool = false) -> [ModelEntry] {
        guard fm.fileExists(atPath: root),
              let en = fm.enumerator(at: URL(fileURLWithPath: root),
                                     includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey, .isSymbolicLinkKey],
                                     options: [.skipsHiddenFiles]) else { return [] }
        var out: [ModelEntry] = []
        let rootURL = URL(fileURLWithPath: root).standardizedFileURL
        for case let url as URL in en {
            let ext = url.pathExtension.lowercased()
            let rel = url.standardizedFileURL.path.dropFirst(rootURL.path.count + 1)
            let parts = rel.split(separator: "/").map(String.init)
            let category = flat ? "" : (parts.count > 1 ? parts[0] : "")
            if bundleDirExtensions.contains(ext) {
                en.skipDescendants()
                out.append(ModelEntry(id: url.path, name: url.lastPathComponent, source: source, category: category,
                                      sizeBytes: dirSize(url), modified: mtime(url), path: url.path))
                continue
            }
            guard let vals = try? url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey, .isSymbolicLinkKey]),
                  vals.isDirectory != true, vals.isSymbolicLink != true else { continue }
            let size = Int64(vals.fileSize ?? 0)
            guard modelExtensions.contains(ext), size >= minFileBytes else { continue }
            out.append(ModelEntry(id: url.path, name: url.lastPathComponent, source: source, category: category,
                                  sizeBytes: size, modified: vals.contentModificationDate ?? .distantPast, path: url.path))
        }
        return out
    }

    /// ~/.cache/huggingface/hub/models--org--name -> one entry per repo, size = blobs.
    static func scanHuggingFace() -> [ModelEntry] {
        let hub = home + "/.cache/huggingface/hub"
        guard let items = try? fm.contentsOfDirectory(atPath: hub) else { return [] }
        return items.filter { $0.hasPrefix("models--") }.map { dir in
            let url = URL(fileURLWithPath: hub + "/" + dir)
            let name = dir.dropFirst("models--".count).replacingOccurrences(of: "--", with: "/")
            return ModelEntry(id: url.path, name: name, source: "Hugging Face cache", category: "hf-cache",
                              sizeBytes: dirSize(url.appendingPathComponent("blobs")), modified: mtime(url), path: url.path)
        }
    }

    /// ~/.ollama/models/manifests/<registry>/<ns>/<model>/<tag> -> "model:tag", size from the manifest layers.
    static func scanOllama() -> [ModelEntry] {
        let base = home + "/.ollama/models/manifests"
        guard let en = fm.enumerator(atPath: base) else { return [] }
        var out: [ModelEntry] = []
        for case let rel as String in en {
            let full = base + "/" + rel
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: full, isDirectory: &isDir), !isDir.boolValue else { continue }
            let parts = rel.split(separator: "/").map(String.init)
            guard parts.count >= 3, let data = fm.contents(atPath: full),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { continue }
            var size: Int64 = 0
            for layer in (json["layers"] as? [[String: Any]]) ?? [] { size += (layer["size"] as? NSNumber)?.int64Value ?? 0 }
            if let cfg = json["config"] as? [String: Any] { size += (cfg["size"] as? NSNumber)?.int64Value ?? 0 }
            let model = parts[parts.count - 2], tag = parts[parts.count - 1]
            let ns = parts.count >= 4 && parts[parts.count - 3] != "library" ? parts[parts.count - 3] + "/" : ""
            out.append(ModelEntry(id: full, name: "\(ns)\(model):\(tag)", source: "Ollama", category: "ollama",
                                  sizeBytes: size, modified: mtime(URL(fileURLWithPath: full)), path: full))
        }
        return out
    }

    static func dirSize(_ url: URL) -> Int64 {
        guard let en = fm.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey, .isSymbolicLinkKey], options: []) else { return 0 }
        var total: Int64 = 0
        for case let f as URL in en {
            if let v = try? f.resourceValues(forKeys: [.fileSizeKey, .isSymbolicLinkKey]), v.isSymbolicLink != true { total += Int64(v.fileSize ?? 0) }
        }
        return total
    }

    static func mtime(_ url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
    }
}

// MARK: - Activity (what is in use right now)

struct ActiveRuntime: Identifiable {
    let id: String           // runtime name
    let state: String        // "running", "idle", "loaded", "offline"
    let detail: String       // human line
    let modelFiles: [String] // file names / model names in use
}

@MainActor
final class ActivityMonitor: ObservableObject {
    @Published var runtimes: [ActiveRuntime] = []
    @Published var activeNames: Set<String> = []   // lowercased file/model names currently in use
    private var timer: Timer?

    func start() {
        poll()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in Task { @MainActor in self?.poll() } }
    }

    func poll() {
        Task.detached(priority: .utility) {
            var out: [ActiveRuntime] = []
            out.append(await Self.comfy())
            if let o = await Self.ollama() { out.append(o) }
            if let l = await Self.lmstudio() { out.append(l) }
            let result = out
            let names = Set(result.filter { $0.state == "running" || $0.state == "loaded" }.flatMap { $0.modelFiles }.map { $0.lowercased() })
            await MainActor.run { self.runtimes = result; self.activeNames = names }
        }
    }

    static func get(_ url: String, timeout: TimeInterval = 1.5) async -> Any? {
        guard let u = URL(string: url) else { return nil }
        var req = URLRequest(url: u); req.timeoutInterval = timeout
        guard let (data, resp) = try? await URLSession.shared.data(for: req), (resp as? HTTPURLResponse)?.statusCode == 200 else { return nil }
        return try? JSONSerialization.jsonObject(with: data)
    }

    /// Model files referenced by a ComfyUI API-format workflow.
    static func modelsIn(workflow: [String: Any]) -> [String] {
        var files: [String] = []
        for (_, node) in workflow {
            guard let n = node as? [String: Any], let inputs = n["inputs"] as? [String: Any] else { continue }
            for key in ["unet_name", "ckpt_name", "clip_name", "clip_name1", "clip_name2", "vae_name", "lora_name", "model_name", "control_net_name", "upscale_model_name"] {
                if let v = inputs[key] as? String { files.append(v) }
            }
        }
        return Array(NSOrderedSet(array: files)) as? [String] ?? files
    }

    static func comfy() async -> ActiveRuntime {
        let base = "http://127.0.0.1:8188"
        guard let stats = await get(base + "/system_stats") as? [String: Any] else {
            return ActiveRuntime(id: "ComfyUI", state: "offline", detail: "not running", modelFiles: [])
        }
        var mem = ""
        if let devs = (stats["devices"] as? [[String: Any]])?.first,
           let total = devs["vram_total"] as? Double, let free = devs["vram_free"] as? Double, total > 0 {
            mem = String(format: "%.0f / %.0f GB memory in use", (total - free) / 1e9, total / 1e9)
        }
        if let q = await get(base + "/queue") as? [String: Any] {
            let running = q["queue_running"] as? [[Any]] ?? []
            let pending = q["queue_pending"] as? [[Any]] ?? []
            if let job = running.first, job.count > 2, let wf = job[2] as? [String: Any] {
                let files = modelsIn(workflow: wf)
                let detail = "running " + (files.isEmpty ? "a job" : files.joined(separator: " + ")) + (pending.isEmpty ? "" : ", \(pending.count) queued") + (mem.isEmpty ? "" : " - " + mem)
                return ActiveRuntime(id: "ComfyUI", state: "running", detail: detail, modelFiles: files)
            }
        }
        // idle: report the last executed job's models
        if let h = await get(base + "/history?max_items=1") as? [String: Any], let last = h.values.first as? [String: Any],
           let p = last["prompt"] as? [Any], p.count > 2, let wf = p[2] as? [String: Any] {
            let files = modelsIn(workflow: wf)
            return ActiveRuntime(id: "ComfyUI", state: "idle", detail: "idle - last used " + files.joined(separator: " + ") + (mem.isEmpty ? "" : " - " + mem), modelFiles: files)
        }
        return ActiveRuntime(id: "ComfyUI", state: "idle", detail: "idle" + (mem.isEmpty ? "" : " - " + mem), modelFiles: [])
    }

    static func ollama() async -> ActiveRuntime? {
        guard let ps = await get("http://127.0.0.1:11434/api/ps") as? [String: Any] else { return nil }
        let models = (ps["models"] as? [[String: Any]] ?? []).compactMap { $0["name"] as? String }
        if models.isEmpty { return ActiveRuntime(id: "Ollama", state: "idle", detail: "running, no model loaded", modelFiles: []) }
        return ActiveRuntime(id: "Ollama", state: "loaded", detail: "loaded " + models.joined(separator: ", "), modelFiles: models)
    }

    static func lmstudio() async -> ActiveRuntime? {
        guard let r = await get("http://127.0.0.1:1234/api/v0/models") as? [String: Any] else { return nil }
        let loaded = (r["data"] as? [[String: Any]] ?? []).filter { ($0["state"] as? String) == "loaded" }.compactMap { $0["id"] as? String }
        if loaded.isEmpty { return ActiveRuntime(id: "LM Studio", state: "idle", detail: "running, no model loaded", modelFiles: []) }
        return ActiveRuntime(id: "LM Studio", state: "loaded", detail: "loaded " + loaded.joined(separator: ", "), modelFiles: loaded)
    }
}

// MARK: - Store

@MainActor
final class Library: ObservableObject {
    @Published var entries: [ModelEntry] = []
    @Published var scanning = false
    @Published var lastScan: Date?
    @AppStorage("extraFolders") private var foldersData: Data = Data()

    static let defaultFolders = [NSHomeDirectory() + "/Documents/development/ComfyUI/models"]

    var folders: [String] {
        get { (try? JSONDecoder().decode([String].self, from: foldersData)) ?? Library.defaultFolders }
        set { foldersData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    func rescan() {
        guard !scanning else { return }
        scanning = true
        let folders = self.folders
        Task.detached(priority: .userInitiated) {
            let result = Scanner.scanAll(extraFolders: folders)
            await MainActor.run {
                self.entries = result
                self.scanning = false
                self.lastScan = Date()
            }
        }
    }

    func addFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true; panel.canChooseFiles = false; panel.allowsMultipleSelection = true
        panel.prompt = "Add"
        if panel.runModal() == .OK {
            var f = folders
            for url in panel.urls where !f.contains(url.path) { f.append(url.path) }
            folders = f
            rescan()
        }
    }

    func removeFolder(_ path: String) {
        folders = folders.filter { $0 != path }
        rescan()
    }
}

// MARK: - Views

struct ActivityStrip: View {
    @EnvironmentObject var activity: ActivityMonitor
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill").foregroundStyle(.tint)
                Text("In use now").font(.headline)
            }
            ForEach(activity.runtimes) { r in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Circle().fill(color(r.state)).frame(width: 8, height: 8)
                    Text(r.id).bold().frame(width: 80, alignment: .leading)
                    Text(r.detail).foregroundStyle(r.state == "offline" ? .secondary : .primary).lineLimit(2).textSelection(.enabled)
                    Spacer()
                }.font(.callout)
            }
            if activity.runtimes.isEmpty { Text("checking...").font(.callout).foregroundStyle(.secondary) }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5))
    }
    func color(_ s: String) -> Color {
        switch s { case "running": return .green; case "loaded": return .green; case "idle": return .yellow; default: return .gray }
    }
}

struct ContentView: View {
    @EnvironmentObject var lib: Library
    @EnvironmentObject var activity: ActivityMonitor
    @State private var selectedSource: String? = nil
    @State private var search = ""
    @State private var sortOrder = [KeyPathComparator(\ModelEntry.sizeBytes, order: .reverse)]
    @State private var selection: ModelEntry.ID?

    var sources: [(String, Int, Int64)] {
        let groups = Dictionary(grouping: lib.entries, by: \.source)
        return groups.keys.sorted().map { ($0, groups[$0]!.count, groups[$0]!.reduce(0) { $0 + $1.sizeBytes }) }
    }

    var filtered: [ModelEntry] {
        lib.entries.filter { e in
            (selectedSource == nil || e.source == selectedSource) &&
            (search.isEmpty || e.name.localizedCaseInsensitiveContains(search) || e.category.localizedCaseInsensitiveContains(search) || e.path.localizedCaseInsensitiveContains(search))
        }.sorted(using: sortOrder)
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSource) {
                Section("Sources") {
                    Label {
                        HStack { Text("All models"); Spacer(); Text("\(lib.entries.count)").foregroundStyle(.secondary) }
                    } icon: { Image(systemName: "square.stack.3d.up") }
                    .tag(String?.none)
                    ForEach(sources, id: \.0) { (name, count, size) in
                        Label {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(name)
                                    Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file)).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer(); Text("\(count)").foregroundStyle(.secondary)
                            }
                        } icon: { Image(systemName: icon(for: name)) }
                        .tag(String?.some(name))
                    }
                }
                Section("Scanned folders") {
                    ForEach(lib.folders, id: \.self) { f in
                        Text(f.replacingOccurrences(of: NSHomeDirectory(), with: "~")).font(.caption).lineLimit(1).truncationMode(.middle)
                            .contextMenu {
                                Button("Reveal in Finder") { NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: f) }
                                Button("Remove from scan", role: .destructive) { lib.removeFolder(f) }
                            }
                    }
                    Button { lib.addFolder() } label: { Label("Add folder...", systemImage: "plus") }.buttonStyle(.plain).foregroundStyle(.tint)
                }
            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        } detail: {
            VStack(spacing: 0) {
                ActivityStrip()
                Divider()
                Table(filtered, selection: $selection, sortOrder: $sortOrder) {
                    TableColumn("Model", value: \.name) { e in
                        HStack(spacing: 6) {
                            if isActive(e) {
                                Circle().fill(.green).frame(width: 8, height: 8).help("In use now")
                            }
                            Text(e.name).help(e.path)
                        }
                    }.width(min: 220, ideal: 360)
                    TableColumn("Type", value: \.category) { e in Text(e.category).foregroundStyle(.secondary) }.width(min: 90, ideal: 130)
                    TableColumn("Source", value: \.source).width(min: 90, ideal: 130)
                    TableColumn("Size", value: \.sizeBytes) { e in Text(e.sizeText).monospacedDigit() }.width(min: 70, ideal: 90)
                    TableColumn("Modified", value: \.modified) { e in Text(e.modified, format: .dateTime.year().month().day()) }.width(min: 90, ideal: 100)
                    TableColumn("Path", value: \.path) { e in
                        Text(e.path.replacingOccurrences(of: NSHomeDirectory(), with: "~")).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                    }.width(min: 200, ideal: 420)
                }
                .contextMenu(forSelectionType: ModelEntry.ID.self) { ids in
                    if let id = ids.first {
                        Button("Reveal in Finder") { NSWorkspace.shared.selectFile(id, inFileViewerRootedAtPath: "") }
                        Button("Copy path") { NSPasteboard.general.clearContents(); NSPasteboard.general.setString(id, forType: .string) }
                    }
                } primaryAction: { ids in
                    if let id = ids.first { NSWorkspace.shared.selectFile(id, inFileViewerRootedAtPath: "") }
                }
                Divider()
                HStack {
                    let total = filtered.reduce(Int64(0)) { $0 + $1.sizeBytes }
                    Text("\(filtered.count) models, \(ByteCountFormatter.string(fromByteCount: total, countStyle: .file))")
                    Spacer()
                    if lib.scanning { ProgressView().controlSize(.small); Text("Scanning...") }
                    else if let t = lib.lastScan { Text("Scanned \(t, format: .dateTime.hour().minute())").foregroundStyle(.secondary) }
                }.font(.callout).padding(.horizontal, 12).padding(.vertical, 6)
            }
            .searchable(text: $search, placement: .toolbar, prompt: "Search name, type or path")
            .navigationTitle(selectedSource ?? "All models")
            .toolbar {
                ToolbarItem { Button { lib.rescan() } label: { Label("Refresh", systemImage: "arrow.clockwise") }.disabled(lib.scanning) }
            }
        }
        .frame(minWidth: 900, minHeight: 500)
        .onAppear { lib.rescan(); activity.start() }
    }

    /// A row is "active" when a runtime reports its file name (ComfyUI) or model name (Ollama / LM Studio).
    func isActive(_ e: ModelEntry) -> Bool {
        let n = e.name.lowercased()
        return activity.activeNames.contains(n) || activity.activeNames.contains { $0.hasSuffix("/" + n) || n.hasSuffix("/" + $0) || $0 == n.replacingOccurrences(of: ".gguf", with: "") }
    }

    func icon(for source: String) -> String {
        switch source {
        case "Hugging Face cache": return "face.smiling"
        case "Ollama": return "terminal"
        case "LM Studio": return "text.bubble"
        case "Torch hub": return "flame"
        default: return "folder"
        }
    }
}

@main
struct ModelLibraryApp: App {
    @StateObject private var lib = Library()
    @StateObject private var activity = ActivityMonitor()
    var body: some Scene {
        WindowGroup("Model Library") {
            ContentView().environmentObject(lib).environmentObject(activity)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Refresh") { lib.rescan() }.keyboardShortcut("r")
                Button("Add Folder...") { lib.addFolder() }.keyboardShortcut("o")
            }
        }
    }
}
