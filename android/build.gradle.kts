allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val injectNamespace = {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null && android.namespace == null) {
                android.namespace = when (project.name) {
                    "blue_thermal_printer" -> "com.kakzaki.blue_thermal_printer"
                    "esc_pos_printer_plus" -> "com.marcosousa.esc_pos_printer_plus"
                    "esc_pos_utils_plus" -> "com.marcosousa.esc_pos_utils_plus"
                    else -> "com.billova.${project.name.replace("-", "_").replace(".", "_")}"
                }
            }
        }
    }

    if (project.state.executed) {
        injectNamespace()
    } else {
        project.afterEvaluate { injectNamespace() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
