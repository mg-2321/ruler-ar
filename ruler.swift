import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var startNode: SCNNode?
    var endNode: SCNNode?
    var lineNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .featurePoint)
        
        guard let result = hitTestResults.first else {
            return
        }
        
        let position = SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
        
        if startNode == nil {
            startNode = createSphereNode(at: position, radius: 0.005, color: .red)
            sceneView.scene.rootNode.addChildNode(startNode!)
        } else if endNode == nil {
            endNode = createSphereNode(at: position, radius: 0.005, color: .blue)
            sceneView.scene.rootNode.addChildNode(endNode!)
            lineNode = createLineNode(from: startNode!.position, to: endNode!.position)
            sceneView.scene.rootNode.addChildNode(lineNode!)
            
            let distance = startNode!.position.distance(to: endNode!.position)
            print("Distance: \(distance)")
        } else {
            startNode?.removeFromParentNode()
            endNode?.removeFromParentNode()
            lineNode?.removeFromParentNode()
            startNode = nil
            endNode = nil
            lineNode = nil
        }
    }
    
    func createSphereNode(at position: SCNVector3, radius: CGFloat, color: UIColor) -> SCNNode {
        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = position
        return sphereNode
    }
    
    func createLineNode(from startPoint: SCNVector3, to endPoint: SCNVector3) -> SCNNode {
        let line = SCNGeometry.line(from: startPoint, to: endPoint)
        let lineNode = SCNNode(geometry: line)
        return lineNode
    }
}

extension SCNGeometry {
    class func line(from startPoint: SCNVector3, to endPoint: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [startPoint, endPoint])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}

extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
}
