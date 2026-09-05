import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

/// Local, untracked configuration. The Google Maps key lives here rather than
/// in the manifest — v1 committed its key and it is now public in git history.
val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

android {
    namespace = "com.erbil.erbilcafe"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications uses java.time on minSdk 23, which needs
        // the desugared JDK libraries backported into the APK.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.erbil.erbilcafe"
        // 23 is the floor for the Google Maps SDK and Flutter itself; v1 still
        // declared 16, which no longer builds.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["mapsApiKey"] =
            localProperties.getProperty("MAPS_API_KEY") ?: ""
    }

    buildTypes {
        release {
            // TODO: replace with a real upload key before publishing.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
