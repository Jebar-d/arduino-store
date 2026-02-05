import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { STLLoader } from 'three/examples/jsm/loaders/STLLoader.js'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
import { OBJLoader } from 'three/examples/jsm/loaders/OBJLoader.js'

let scene, camera, renderer, controls, model

export function mountViewer(canvas, fileURL) {
  scene = new THREE.Scene()
  scene.background = new THREE.Color(0xf5f5f5)

  const aspect = canvas.clientWidth / canvas.clientHeight
  camera = new THREE.PerspectiveCamera(45, aspect, 0.1, 1000)
  camera.position.set(0, 0, 8)

  renderer = new THREE.WebGLRenderer({ canvas, antialias: true })
  renderer.setSize(canvas.clientWidth, canvas.clientHeight)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

  const ambient = new THREE.AmbientLight(0xffffff, 0.7)
  scene.add(ambient)
  const dir = new THREE.DirectionalLight(0xffffff, 0.8)
  dir.position.set(5, 10, 7.5)
  scene.add(dir)

  controls = new OrbitControls(camera, renderer.domElement)
  controls.enableDamping = true

  loadModel(fileURL)

  window.addEventListener('resize', onResize)
  animate()
}

function loadModel(url) {
  // Extract extension from URL or filename
  const urlLower = url.toLowerCase()
  let ext = ''
  
  if (urlLower.endsWith('.stl')) ext = 'stl'
  else if (urlLower.endsWith('.obj')) ext = 'obj'
  else if (urlLower.endsWith('.glb')) ext = 'glb'
  else if (urlLower.endsWith('.gltf')) ext = 'gltf'
  else {
    // Try to get from URL path
    const match = urlLower.match(/\.(stl|obj|glb|gltf)(?:\?|$)/)
    ext = match ? match[1] : ''
  }
  
  if (!ext) {
    console.error('Cannot determine 3D file type from URL:', url)
    return
  }
  
  console.log('Loading 3D model, type:', ext, 'URL:', url)

  let loader
  if (ext === 'stl') loader = new STLLoader()
  else if (ext === 'obj') loader = new OBJLoader()
  else if (ext === 'glb' || ext === 'gltf') loader = new GLTFLoader()
  
  loader.load(
    url,
    (result) => {
      console.log('3D model loaded successfully')
      
      const mesh = result.isScene || result.scene 
        ? result.scene || result 
        : new THREE.Mesh(
            result,
            new THREE.MeshStandardMaterial({ 
              color: 0x29b6f6, 
              metalness: 0.3, 
              roughness: 0.4 
            })
          )

      // Center and scale
      const box = new THREE.Box3().setFromObject(mesh)
      const size = box.getSize(new THREE.Vector3()).length()
      const center = box.getCenter(new THREE.Vector3())
      
      mesh.position.sub(center)
      const scale = size > 0 ? 5 / size : 1
      mesh.scale.setScalar(scale)

      scene.add(mesh)
      model = mesh
      
      // Auto-rotate for showcase
      controls.autoRotate = true
      controls.autoRotateSpeed = 2.0
    },
    (progress) => {
      console.log('Loading progress:', (progress.loaded / progress.total * 100) + '%')
    },
    (err) => {
      console.error('3D load error:', err)
      // Show error on canvas
      const canvas = renderer?.domElement
      if (canvas) {
        const ctx = canvas.getContext('2d')
        if (ctx) {
          ctx.fillStyle = '#1c1c1f'
          ctx.fillRect(0, 0, canvas.width, canvas.height)
          ctx.fillStyle = '#f44'
          ctx.font = '16px sans-serif'
          ctx.fillText('Failed to load 3D model', 20, 50)
          ctx.fillStyle = '#888'
          ctx.font = '12px sans-serif'
          ctx.fillText('Check console for details', 20, 80)
        }
      }
    }
  )
}
function onResize() {
  const w = renderer.domElement.clientWidth
  const h = renderer.domElement.clientHeight
  camera.aspect = w / h
  camera.updateProjectionMatrix()
  renderer.setSize(w, h)
}

function animate() {
  requestAnimationFrame(animate)
  controls.update()
  renderer.render(scene, camera)
}