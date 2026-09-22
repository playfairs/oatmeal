kotlin {
    sourceSets {
        main {
            kotlin.setSrcDirs(listOf("src"))
            resources.setSrcDirs(listOf("resources"))
        }
        test {
            kotlin.setSrcDirs(listOf("test"))
        }
    }
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
        vendor = JvmVendorSpec.JETBRAINS
    }
}

plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.compose)
    alias(libs.plugins.compose.compiler)
    kotlin("plugin.serialization") version "2.0.20"
    application
}

repositories {
    mavenCentral()
    google()
    maven("https://packages.jetbrains.team/maven/p/ij/intellij-dependencies")
}

val jewelVersion = "0.28.0-251.26137"

dependencies {
    // Use the Kotlin Test integration.
    testImplementation("org.jetbrains.kotlin:kotlin-test")

    // Use the JUnit 5 integration.
    testImplementation(libs.junit.jupiter.engine)

    testRuntimeOnly("org.junit.platform:junit-platform-launcher")

    // This dependency is used by the application.
    implementation(libs.guava)

    implementation(compose.desktop.currentOs)
    implementation(compose.foundation)
    implementation(compose.ui)

    implementation("org.jetbrains.jewel:jewel-foundation:$jewelVersion")
    implementation("org.jetbrains.jewel:jewel-ui:$jewelVersion")
    implementation("org.jetbrains.jewel:jewel-int-ui-decorated-window:$jewelVersion")
    implementation("org.jetbrains.jewel:jewel-decorated-window:$jewelVersion")
    implementation("org.jetbrains.jewel:jewel-int-ui-standalone:$jewelVersion")

    implementation("org.apache.logging.log4j:log4j-api:2.20.0")
    implementation("org.apache.logging.log4j:log4j-core:2.20.0")

    implementation("com.akuleshov7:ktoml-core:0.5.1")

    constraints {
        implementation("org.jetbrains.skiko:skiko-awt-runtime-macos-arm64:0.9.2") {
            because("Jewel pulls in an old Skiko native runtime that lacks RenderNodeContext support")
        }
    }

    implementation(compose.desktop.currentOs) {
        exclude(group = "org.jetbrains.compose.material")
    }
}


application {
    mainClass = "cc.playfairs.oatmeal.Main"
}

tasks.jar {
    entryCompression = ZipEntryCompression.STORED
}

tasks.named<Test>("test") {
    // Use JUnit Platform for unit tests.
    useJUnitPlatform()
}
