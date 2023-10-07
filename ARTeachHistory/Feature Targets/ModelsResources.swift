//
//  ModelsResources.swift
//  ARTeachHistory
//
//  Created by Cyril DOUCHET on 06/10/2023.
//

import Foundation
import RealityKit

actor LoadingWatcher {
    var completedLoadings: Float = 0
    
    func increment() {
        completedLoadings += 1
    }
}

class ModelsResources {
    public var models = [String : Entity]()
    
    init() {}
    
    public func getModel(name: String) -> Entity {
        return models[name].unsafelyUnwrapped
    }
    
    private func loadModel(model: String) async -> Void {
        do {
            print("Loading model: \(model)")
//            let loadRequest = await Entity.loadModelAsync(named: model, in: Bundle.main)
//            let loaded = try loadRequest.result.unsafelyUnwrapped.get()
//            let loaded = try await (Entity.loadAsync(named: model, in: Bundle.main)).result.unsafelyUnwrapped.get()
            let loaded = await (try? Entity.load(named: model, in: Bundle.main)).unsafelyUnwrapped
            models[model] = loaded
        } catch {
            print("FATAL: Could not load resources: \(error.localizedDescription)")
        }
    }
    
    public func loadResources(onProgress: @escaping (Float) -> Void) async {
        
        if let bundlePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            do {
                let content = try fileManager.contentsOfDirectory(atPath: bundlePath)
                var models: Set<String> = []
                for file in content {
                    if file.localizedStandardContains(".usdz") {
                        models.insert(String(file.split(separator: ".").first.unsafelyUnwrapped))
                    }
                }
                let count = Float(models.count)
                let loadingWatcher = LoadingWatcher()
                
                await withTaskGroup(of: Void.self) {
                    group in
                    for model in models {
                        group.addTask {
                            await self.loadModel(model: model)
                            await loadingWatcher.increment()
                            onProgress(((await loadingWatcher.completedLoadings) / count) * 100)
                        }
                    }
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        } else {
            print("Did not find !!!")
        }
    }
}
