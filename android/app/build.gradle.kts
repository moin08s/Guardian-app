plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "guardianai.com.guardian_ai"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "guardianai.com.guardian_ai"
        minSdk = 24
        targetSdk = 36

        // Use .toInt() to ensure type safety in Kotlin DSL
        versionCode = flutter.versionCode?.toInt() ?: 1
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    // Fixed: All these blocks must stay INSIDE the android block
    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    configurations.all {
        resolutionStrategy {
            // Force older versions that work with AGP 8.7.0
            force("androidx.browser:browser:1.8.0")
            force("androidx.core:core-ktx:1.15.0")
            force("androidx.core:core:1.15.0")

            // Keep your existing Kotlin forces
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.1.0")
        }
    }
}
flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.10.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-database")
    implementation("com.google.firebase:firebase-messaging")
    implementation("androidx.multidex:multidex:2.0.1")
}