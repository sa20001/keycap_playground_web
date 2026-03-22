import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader';
import SevenZip from '7z-wasm';
import wasmUrl from '7z-wasm/7zz.wasm?url';

export class ModelLoader {
  private readonly loader: GLTFLoader;

  constructor() {
    this.loader = new GLTFLoader();
  }

  parseGLB(
    arrayBuffer: ArrayBuffer,
  ): Promise<THREE.Object3D> {
    return new Promise((resolve, reject) => {
      this.loader.parse(
        arrayBuffer,
        '',
        (gltf) => {
          resolve(gltf.scene);
        },
        (error) => {
          reject(error);
        },
      );
    });
  }

  async extract7z(file: Blob): Promise<File[]> {
    const sevenZip = await SevenZip({
      locateFile: () => wasmUrl,
    });

    const data = new Uint8Array(
      await file.arrayBuffer(),
    );

    const archiveName = 'model.7z';

    const stream = sevenZip.FS.open(
      archiveName,
      'w+',
    );

    sevenZip.FS.write(
      stream,
      data,
      0,
      data.length,
    );

    sevenZip.FS.close(stream);

    sevenZip.callMain([
      'x',
      archiveName,
    ]);

    const names = sevenZip.FS.readdir('/').filter(
      (name) =>
        name !== '.' &&
        name !== '..' &&
        name.toLowerCase().endsWith('.glb'),
    );

    return names.map((name) => {
      const bytes = sevenZip.FS.readFile(name);
      const buffer = new ArrayBuffer(bytes.byteLength);

      new Uint8Array(buffer).set(bytes);

      return new File([buffer], name);
    });
  }

  async parse7z(file: Blob): Promise<THREE.Object3D[]> {
    const files = await this.extract7z(file);

    const glbFiles = files.filter(
      (file) => file.name.toLowerCase().endsWith('.glb'),
    );

    const models = await Promise.all(
      glbFiles.map(async (file) => {
        const arrayBuffer = await file.arrayBuffer();

        return this.parseGLB(arrayBuffer);
      }),
    );

    return models;
  }
  
}