//
//  CustomARView.swift
//  ARTeachHistory
//
//  Created by Cyril DOUCHET on 05/10/2023.
//

import ARKit
import RealityKit
import SwiftUI

class CustomARView: ARView {
    let modelsResources = ModelsResources()
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addGestures() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    private func loadResources() {
        Task {
            await modelsResources.loadResources(onProgress: { percentage in
                print("Percentage progress: \(percentage)")
            })
        }
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        self.config()
        self.addGestures()
        self.loadResources()
        
        
        
        
        //        let tabac = (try? Entity.load(named: "tabac")).unsafelyUnwrapped
        let anchor = AnchorEntity(world: .zero)
        //        anchor.addChild(tabac)
        scene.addAnchor(anchor)
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        let results = self.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            let worldPosition = simd_make_float3(firstResult.worldTransform.columns.3)
            let worldRotation = simd_make_float3(firstResult.worldTransform.columns.1)
            
            self.placeTobacco(at: worldPosition, rotation: worldRotation)
        }
    }
    
    private func placeTobacco(at location: SIMD3<Float>, rotation: SIMD3<Float>) {
        let objectAnchor = AnchorEntity(world: location)
        let angle = -atan2(location.x, location.z)
        
        let temple = modelsResources.getModel(name: "temple")
        
        temple.orientation = simd_quatf(angle: angle, axis: SIMD3(x: 0, y: 1, z: 0))
        
        
        objectAnchor.addChild(temple)
        scene.addAnchor(objectAnchor)
    }
    
    
    
    //    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    //        for anchor in anchors {
    //            if let planeAnchor = anchor as? ARPlaneAnchor {
    ////                let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
    ////                let material = SCNMaterial()
    ////                material.diffuse.contents = UIColor.green
    ////                planeGeometry.materials = [material]
    ////                let planeNode = SCNNode(geometry: planeGeometry)
    ////                planeNode.eulerAngles.x = -.pi / 2
    ////                planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
    //
    //                let mesh = MeshResource.generatePlane(width: planeAnchor.planeExtent.width, depth: 0.5)
    //                let material = SimpleMaterial(color: SimpleMaterial.Color(displayP3Red: CGFloat(255), green: CGFloat(255), blue: CGFloat(255), alpha: CGFloat(0.5)), isMetallic: false)
    //
    //                let entity = ModelEntity(mesh: mesh, materials: [material])
    //
    //                let anchor = AnchorEntity(plane: .horizontal)
    //                anchor.position = SIMD3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
    //                anchor.addChild(entity)
    //
    //                scene.addAnchor(anchor)
    //            }
    //        }
    //    }
    
    private func getAnchorFromARAnchor(_ anchor: ARAnchor) -> HasAnchoring? {
        return scene.anchors.first(where: {
            if $0.anchorIdentifier != nil {
                return $0.anchorIdentifier == anchor.identifier
            }
            return false
        })
    }
    
    //    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
    //        for anchor in anchors {
    //            let a = getAnchorFromARAnchor(anchor)
    //            if (a != nil) {
    //                scene.removeAnchor(a!)
    //            }
    //        }
    //    }
    //
    //    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    //        print("Updating anchors positions")
    //        for anchor in anchors {
    //            let a = getAnchorFromARAnchor(anchor)
    //            a?.position.x = anchor.transform.columns.0.x
    //            a?.position.y = anchor.transform.columns.0.y
    //            a?.position.z = anchor.transform.columns.0.z
    //        }
    //    }
    
    
    
    //    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //        // Place content only for anchors found by plane detection.
    //        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    //
    //        // Create a custom object to visualize the plane geometry and extent.
    //        let plane = Plane(anchor: planeAnchor, in: sceneView)
    //
    //
    //        // Add the visualization to the ARKit-managed node so that it tracks
    //        // changes in the plane anchor as plane estimation continues.
    //        node.addChildNode(plane)
    //        self.
    //    }
    
    
    
    func config() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        self.environment.sceneUnderstanding.options.insert(.receivesLighting)
        session.run(configuration)
    }
}
