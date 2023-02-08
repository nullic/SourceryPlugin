import Foundation
import PackagePlugin

@main
struct SourceryPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        var configurations: [Path] = []

        let rootConfigs = try self.configurations(in: context.package.directory)
        let targetConfigs = try self.configurations(in: target.directory)

        configurations.append(contentsOf: rootConfigs)
        configurations.append(contentsOf: targetConfigs)

        let sourcery = try context.tool(named: "sourcery")
        guard !configurations.isEmpty else {
            Diagnostics.warning("No SourceryPlugin configurations found for target: \(target.name).")
            return []
        }

        return configurations.map { config in
            .prebuildCommand(
                displayName: "SourceryPlugin BuildTool Plugin",
                executable: sourcery.path,
                arguments: ["--config", config.string,
                            "--disableCache",
                            "--prune"],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        }
    }

    private func configurations(in path: Path) throws -> [Path] {
        var configurations: [Path] = []
        for file in try FileManager.default.contentsOfDirectory(atPath: path.string).sorted() {
            if file.hasSuffix("sourcery.yml") {
                let configPath = path.appending(file)
                Diagnostics.remark("Found config at: \(configPath.string)")
                configurations.append(configPath)
            }
        }
        return configurations
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SourceryPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let configurations: [Path] = try self.configurations(in: context.xcodeProject.directory)

        let sourcery = try context.tool(named: "sourcery")
        guard !configurations.isEmpty else {
            Diagnostics.warning("No SourceryPlugin configurations found for target: \(target.displayName).")
            return []
        }

        return configurations.map { config in
            .prebuildCommand(
                displayName: "SourceryPlugin BuildTool Plugin",
                executable: sourcery.path,
                arguments: ["--config", config.string,
                            "--prune"],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        }
    }
}
#endif
