import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';

export class ViewerEngine {
  readonly scene: THREE.Scene;
  readonly camera: THREE.PerspectiveCamera;
  readonly renderer: THREE.WebGLRenderer;
  controls: OrbitControls;
  readonly modelGroup: THREE.Group;

  constructor(
    private readonly container: HTMLElement,
  ) {
    this.scene = new THREE.Scene();
    this.scene.background =
      new THREE.Color(0xf0f0f0);

    this.camera =
      new THREE.PerspectiveCamera(
        45,
        1,
        0.01,
        1000,
      );

    this.renderer =
      new THREE.WebGLRenderer({
        antialias: true,
      });

    this.renderer.setPixelRatio(
      window.devicePixelRatio || 1,
    );

    this.modelGroup =
      new THREE.Group();

    this.scene.add(
      this.modelGroup,
    );

    this.initLights();
    this.initControls();

    this.renderer.domElement.addEventListener(
      'contextmenu',
      (event) => event.preventDefault(),
    );
  }

  private initLights() {
    const hemi =
      new THREE.HemisphereLight(
        0xffffff,
        0x444444,
        1.2,
      );

    hemi.position.set(
      0,
      200,
      0,
    );

    this.scene.add(hemi);

    const dir =
      new THREE.DirectionalLight(
        0xffffff,
        0.8,
      );

    dir.position.set(
      0,
      20,
      10,
    );

    this.scene.add(dir);
  }

  private initControls() {
    this.controls =
      new OrbitControls(
        this.camera,
        this.renderer.domElement,
      );

    this.controls.enableDamping = true;
    this.controls.dampingFactor = 0.08;
    this.controls.screenSpacePanning = false;

    this.controls.minDistance = 0.01;
    this.controls.maxDistance = 1000;

    this.controls.mouseButtons = {
      LEFT: THREE.MOUSE.ROTATE,
      MIDDLE: THREE.MOUSE.PAN,
    };
  }

  resize(
    width: number,
    height: number,
  ) {
    this.camera.aspect =
      width / height;

    this.camera.updateProjectionMatrix();

    this.renderer.setSize(
      width,
      height,
    );
  }

  render() {
    this.controls.update();

    this.renderer.render(
      this.scene,
      this.camera,
    );
  }

  dispose() {
    this.controls.dispose();
    this.renderer.dispose();
  }
}