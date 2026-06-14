plugins {
    // Standard Flutter and Android plugins
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("dev.flutter.flutter-gradle-plugin") apply false

    // UPDATED: Version 4.4.2 is required for SDK 36 stability
    id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory logic (standard for Flutter)
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
    // This ensures that the app settings (Firebase, etc.)
    // are loaded before any plugins try to use them.
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}