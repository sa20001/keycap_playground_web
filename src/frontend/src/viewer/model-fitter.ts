import * as THREE from 'three';

export class ModelFitter {
  constructor(
    private readonly camera: THREE.PerspectiveCamera,
    private readonly controls: {
      target: THREE.Vector3;
      update: () => void;
    },
  ) {}

  fit(
    object: THREE.Object3D,
  ) {
    const box =
      new THREE.Box3().setFromObject(object);

    if (box.isEmpty()) {
      return;
    }

    const size =
      box.getSize(new THREE.Vector3());

    const center =
      box.getCenter(new THREE.Vector3());

    const maxSize = Math.max(
      size.x,
      size.y,
      size.z,
    );

    const fitOffset = 1.4;

    const distance =
      maxSize /
      (2 *
        Math.tan(
          Math.PI *
            this.camera.fov /
            360,
        )) *
      fitOffset;

    this.camera.position.copy(
      center.clone().add(
        new THREE.Vector3(
          distance,
          distance * 0.7,
          distance,
        ),
      ),
    );

    this.camera.near = Math.max(
      0.01,
      distance / 1000,
    );

    this.camera.far =
      distance * 1000;

    this.camera.updateProjectionMatrix();

    this.controls.target.copy(center);
    this.controls.update();
  }
}