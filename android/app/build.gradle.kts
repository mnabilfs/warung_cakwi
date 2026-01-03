// ================= IMPORT =================
import java.util.Properties
import java.io.FileInputStream

// ================= PLUGINS =================
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase
}

// ================= ANDROID CONFIG =================
android {
    namespace = "com.example.gerai_bakso"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    // ---------- Java & Kotlin ----------
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // ---------- Default Config ----------
    defaultConfig {
        applicationId = "com.example.gerai_bakso"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    // ---------- SIGNING CONFIG ----------
    signingConfigs {
        create("release") {
            val keystoreProperties = Properties()
            val keystoreFile = rootProject.file("key.properties")

            if (!keystoreFile.exists()) {
                throw GradleException("❌ key.properties file not found")
            }

            keystoreProperties.load(FileInputStream(keystoreFile))

            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    // ---------- BUILD TYPES ----------
    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }

        debug {
            isMinifyEnabled = false
        }
    }
}

// ================= FLUTTER =================
flutter {
    source = "../.."
}

// ================= DEPENDENCIES =================
dependencies {
    // Java 8+ API support
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase Cloud Messaging
    implementation("com.google.firebase:firebase-messaging:23.4.0")

    // Multidex
    implementation("androidx.multidex:multidex:2.0.1")
}
