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

// اعمال تنظیمات اجباری برای رفع ارورهای پکیج‌های قدیمی
subprojects {
    plugins.withId("com.android.library") {
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
            // 1. رفع مشکل namespace
            if (namespace.isNullOrEmpty()) {
                namespace = project.group.toString().ifEmpty { "com.example.${project.name.replace("-", "_")}" }
            }
            // 2. رفع مشکل lStar با اجبار به استفاده از SDK 34
            if (compileSdk == null || compileSdk!! < 34) {
                compileSdk = 34
            }
        }
    }
    
    // 3. تحمین نسخه‌های سازگار برای جلوگیری از ارور AGP 8.9.1
    configurations.all {
        resolutionStrategy {
            force("androidx.browser:browser:1.8.0")
            force("androidx.core:core-ktx:1.13.1")
            force("androidx.core:core:1.13.1")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}