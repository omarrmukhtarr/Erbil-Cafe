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
// Older plugins still declare compileSdk 31, which current AndroidX artifacts
// refuse to link against. Pin every module up rather than waiting on each
// plugin to update.
//
// This block must come before the evaluationDependsOn one below: that call
// evaluates the project immediately, after which afterEvaluate can no longer
// be registered.
subprojects {
    afterEvaluate {
        val androidExtension = project.extensions.findByName("android")
        if (androidExtension is com.android.build.gradle.BaseExtension) {
            val current = androidExtension.compileSdkVersion
                ?.substringAfter("android-")
                ?.toIntOrNull()
            if (current == null || current < 36) {
                androidExtension.compileSdkVersion(36)
            }
            androidExtension.compileOptions.apply {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
