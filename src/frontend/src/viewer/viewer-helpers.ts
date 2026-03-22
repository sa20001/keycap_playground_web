import * as THREE from 'three';

export class ViewerHelpers {
  grid?: THREE.GridHelper;
  axes?: THREE.AxesHelper;

  constructor(
    private readonly scene: THREE.Scene,
    private readonly showGrid: boolean,
    private readonly showAxes: boolean,
  ) {
    this.initialize();
  }

  private initialize() {
    if (this.showGrid) {
      this.grid = this.createGrid();
      this.scene.add(this.grid);
    }

    if (this.showAxes) {
      this.axes = this.createAxes();
      this.scene.add(this.axes);
    }
  }

  private createGrid(): THREE.GridHelper {
    const grid = new THREE.GridHelper(
      200,
      40,
      0x888888,
      0xdddddd,
    );

    const material =
      grid.material as THREE.Material;

    material.opacity = 0.6;
    material.transparent = true;

    return grid;
  }

  private createAxes(): THREE.AxesHelper {
    return new THREE.AxesHelper(50);
  }

  toggleGrid() {
    if (this.grid) {
      this.grid.visible =
        !this.grid.visible;
      return;
    }

    this.grid = this.createGrid();
    this.scene.add(this.grid);
  }

  toggleAxes() {
    if (this.axes) {
      this.axes.visible =
        !this.axes.visible;
      return;
    }

    this.axes = this.createAxes();
    this.scene.add(this.axes);
  }
}