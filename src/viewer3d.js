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
  const ext = url.split('.').pop().toLowerCase()
  let loader
  if (ext === 'stl') loader = new STLLoader()
  else if (ext === 'obj') loader = new OBJLoader()
  else if (ext === 'glb' || ext === 'gltf') loader = new GLTFLoader()
  else return console.warn('unsupported 3-D extension')

  loader.load(
    url,
    (geometry) => {
      const mesh = geometry.isScene
        ? geometry.scene
        : new THREE.Mesh(
            geometry,
            new THREE.MeshStandardMaterial({ color: 0x29b6f6, metalness: 0.2, roughness: 0.6 })
          )

      const box = new THREE.Box3().setFromObject(mesh)
      const size = box.getSize(new THREE.Vector3()).length()
      const center = box.getCenter(new THREE.Vector3())
      mesh.position.sub(center)
      const scale = 4 / size
      mesh.scale.setScalar(scale)
      scene.add(mesh)
      model = mesh
    },
    undefined,
    (err) => console.error('3-D load error', err)
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