allprojects {
    repositories {
        google()
        mavenCentral()
    }
    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.addAll(listOf("-Xlint:unchecked", "-Xlint:deprecation", "-Xlint:-options"))
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.android.tools.build" && requested.name == "gradle") {
                // Not the right place for namespace, but just checking
            }
        }
    }
}

// Global workaround for missing namespaces and Java compatibility in older plugins
subprojects {
    val fixProject = {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                // 1. Fix namespace in build.gradle
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                if (getNamespace.invoke(android) == null) {
                    val packageName = "com.${project.name.replace("-", ".").replace("_", ".")}"
                    setNamespace.invoke(android, packageName)
                    // println("Fixed namespace for ${project.name} to $packageName")
                }
                
                // 2. Fix duplicate package in AndroidManifest.xml
                if (project.name == "flutter_system_ringtones") {
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val text = manifestFile.readText()
                        if (text.contains("package=")) {
                            val newText = text.replace(Regex("package=\"[^\"]*\""), "")
                            manifestFile.writeText(newText)
                            // println("Stripped package attribute from ${project.name} manifest")
                        }
                    }
                }

                // 3. Enforce Java 11
                val compileOptions = android.javaClass.getMethod("getCompileOptions").invoke(android)
                compileOptions.javaClass.getMethod("setSourceCompatibility", JavaVersion::class.java).invoke(compileOptions, JavaVersion.VERSION_11)
                compileOptions.javaClass.getMethod("setTargetCompatibility", JavaVersion::class.java).invoke(compileOptions, JavaVersion.VERSION_11)

                // Configure Toolchain
                try {
                    val javaExtension = project.extensions.findByType(JavaPluginExtension::class.java)
                    javaExtension?.toolchain?.languageVersion?.set(JavaLanguageVersion.of(21))
                } catch (e: Exception) {
                    // Plugin might not have JavaPluginExtension
                }
            } catch (e: Exception) {
                // Ignore
            }

            // 4. Enforce Kotlin JVM Target
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().all {
                kotlinOptions {
                    jvmTarget = "11"
                }
            }
        }
    }

    if (project.state.executed) {
        fixProject()
    } else {
        project.afterEvaluate {
            fixProject()
        }
    }
}
subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            freeCompilerArgs = freeCompilerArgs + listOf("-Xlint:deprecation")
        }
    }
}