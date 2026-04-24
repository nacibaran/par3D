import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    PrincipledMaterial {
        id: mat_Yellow_material
        objectName: "Mat_Yellow"
        baseColor: "#ffc6955d"
        roughness: 1
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: mat_Black_material
        objectName: "Mat_Black"
        baseColor: "#ff0e0e0e"
        roughness: 1
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: principledMaterial
        metalness: 1
        roughness: 1
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: mat_White_material
        objectName: "Mat_White"
        baseColor: "#ff7b7b7b"
        roughness: 0.5
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: mat_White_002_material
        objectName: "Mat_White.002"
        baseColor: "#ff7b7b7b"
        roughness: 0.5
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: mat_White_001_material
        objectName: "Mat_White.001"
        baseColor: "#ff7b7b7b"
        roughness: 0.5
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: material_092_material
        objectName: "Material.092"
        baseColor: "#ff000000"
        roughness: 0.914634108543396
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: mat_Black_003_material
        objectName: "Mat_Black.003"
        baseColor: "#ff0e0e0e"
        roughness: 0.5
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: mat_Black_002_material
        objectName: "Mat_Black.002"
        baseColor: "#ff0e0e0e"
        roughness: 0.5
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }

    // Nodes:
    Model {
        id: body
        objectName: "Body"
        position: Qt.vector3d(0.0146628, 0.611852, 0.00920051)
        source: "meshes/body_mesh.mesh"
        materials: [
            mat_Yellow_material,
            mat_Black_material,
            principledMaterial
        ]
        Model {
            id: light_Front
            objectName: "Light_Front"
            position: Qt.vector3d(0.00548152, -0.0668365, 0.573295)
            source: "meshes/far_mesh.mesh"
            materials: [
                mat_White_material
            ]
        }
        Model {
            id: light_Rear
            objectName: "Light_Rear"
            position: Qt.vector3d(0.00708617, -0.0785723, -0.589341)
            source: "meshes/far_002_mesh.mesh"
            materials: [
                mat_White_002_material
            ]
        }
        Model {
            id: light_Soma
            objectName: "Light_Soma"
            position: Qt.vector3d(0.00977064, 0.310432, 0.0101441)
            source: "meshes/node0019_0000___Par_a2_1_004_mesh.mesh"
            materials: [
                mat_White_001_material
            ]
        }
        Model {
            id: mast_Panel
            objectName: "Mast_Panel"
            position: Qt.vector3d(0.00488091, 0.118379, -0.00744402)
            rotation: Qt.quaternion(0.707107, 0.707107, 0, 0)
            scale: Qt.vector3d(1, 1, 1)
            source: "meshes/mast_Panel_Mesh_mesh.mesh"
            materials: [
                material_092_material
            ]
            Model {
                id: mast_G_vde_
                objectName: "Mast_Gövde "
                position: Qt.vector3d(-0.0249105, -0.00977588, -0.458085)
                rotation: Qt.quaternion(0.992132, 0, 0, -0.125193)
                source: "meshes/mast_G_vde_Mesh_mesh.mesh"
                materials: [
                    mat_Black_material
                ]
                Model {
                    id: mast_Kol_1
                    objectName: "Mast_Kol_1"
                    position: Qt.vector3d(-0.0645537, -0.0487076, 0.205656)
                    rotation: Qt.quaternion(0.701543, 0.701544, 0.088525, 0.088525)
                    source: "meshes/mast_Kol_1_Mesh_mesh.mesh"
                    materials: [
                        mat_Black_material
                    ]
                    Model {
                        id: mast_Kol_2
                        objectName: "Mast_Kol_2"
                        position: Qt.vector3d(0.0247254, -0.0572071, -0.0178635)
                        rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
                        scale: Qt.vector3d(1, 1, 1)
                        source: "meshes/mast_Kol_2_Mesh_mesh.mesh"
                        materials: [
                            mat_Black_material
                        ]
                        Model {
                            id: cevreIzlemeGovde
                            objectName: "CevreIzlemeGovde"
                            position: Qt.vector3d(-0.0119098, -0.00615443, -0.466318)
                            rotation: Qt.quaternion(0.5, -0.5, 0.5, 0.5)
                            source: "meshes/cevreIzlemeGovde_Mesh_mesh.mesh"
                            materials: [
                                mat_Black_material
                            ]
                            Model {
                                id: cevreIzleme
                                objectName: "CevreIzleme"
                                position: Qt.vector3d(0.167745, 0.000624537, 0.0244011)
                                source: "meshes/cevreIzleme_Mesh_mesh.mesh"
                                materials: [
                                    mat_Black_material
                                ]
                                Model {
                                    id: ptz
                                    objectName: "PTZ"
                                    position: Qt.vector3d(0.025017, -0.165596, -0.00380224)
                                    source: "meshes/ptz_Mesh_mesh.mesh"
                                    materials: [
                                        mat_Black_material
                                    ]
                                }
                            }
                        }
                    }
                }
            }
        }
        Model {
            id: palet_Front
            objectName: "Palet_Front"
            position: Qt.vector3d(0.00326221, -0.289826, 0.387203)
            rotation: Qt.quaternion(-2.8213e-07, 1, 0, 0)
            scale: Qt.vector3d(-1, -1, -1)
            source: "meshes/front_Track_Mesh_mesh.mesh"
            materials: [
                mat_Black_003_material
            ]
        }
        Model {
            id: palet_Rear
            objectName: "Palet_Rear"
            position: Qt.vector3d(-0.00575379, -0.289826, -0.405605)
            source: "meshes/rear_Track_Mesh_mesh.mesh"
            materials: [
                mat_Black_002_material
            ]
        }
        Model {
            id: sisHavan_
            objectName: "SisHavanı"
            position: Qt.vector3d(-0.430965, 0.310678, 0.813804)
            rotation: Qt.quaternion(-0.21974, -0.21974, 0.672097, -0.672097)
            scale: Qt.vector3d(1, 1, 1)
            source: "meshes/fsm_0000__AynalamaSEPET_ASSEMBLY_R05_2_Aynalamasis_montaj_mesh.mesh"
            materials: [
                mat_Black_material
            ]
        }
        Model {
            id: sisHavan_2
            objectName: "SisHavanı2"
            position: Qt.vector3d(0.472148, 0.310678, 0.799007)
            rotation: Qt.quaternion(0.559167, 0.559167, -0.432819, 0.432819)
            source: "meshes/fsm_0000___AynalamaSEPET_ASSEMBLY_R05_2_Aynalamasis_montaj_1_mesh.mesh"
            materials: [
                mat_Black_material
            ]
        }
    }

    // Animations:
}
