package cc.playfairs.oatmeal.config

import com.akuleshov7.ktoml.Toml
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import org.apache.logging.log4j.LogManager
import java.io.File

object AppConfig {
    private val logger = LogManager.getLogger(AppConfig::class.java)

    @Serializable
    enum class Theme {
        @SerialName("dark") Dark,
        @SerialName("light") Light,
    }

    @Serializable
    enum class Position {
        @SerialName("top-left") TopLeft,
        @SerialName("top-center") TopCenter,
        @SerialName("top-right") TopRight,
        @SerialName("bottom-left") BottomLeft,
        @SerialName("bottom-center") BottomCenter,
        @SerialName("bottom-right") BottomRight,
    }

    @Serializable
    data class Appearance(
        val theme: Theme = Theme.Dark,
        val position: Position = Position.TopCenter,
        val duration: Double = 1.0,

        @SerialName("launch_on_login") 
        val loginLaunch: Boolean = false,
    )

    @Serializable
    data class Keybind(
        val keys: List<String> = emptyList(),
        val name: String = "",
    )

    @Serializable
    data class Config(
        val preferences: Appearance = Appearance(),
        val keybinds: List<Keybind> = emptyList(),
    )

    fun loadConfig(): Config {
        val configFile = getOrCreateConfigFile()

        logger.info("Loading config from: ${configFile.absolutePath}")
        val tomlContent = configFile.readText()

        return try {
            Toml.decodeFromString(Config.serializer(), tomlContent)
        } catch (e: Exception) {
            logger.error("Failed to parse config file (${e.message}), falling back to default Config.")
            Config()
        }
    }

    fun getOrCreateConfigFile(): File {
        val candidates = getConfigSearchPaths()

        val existingFile = candidates.firstOrNull { it.exists() }
        if (existingFile != null) {
            return existingFile
        }

        val targetFile = candidates.first()

        try {
            targetFile.parentFile?.mkdirs()

            val defaultConfig = Config()
            val defaultToml = Toml.encodeToString(Config.serializer(), defaultConfig)

            targetFile.writeText(defaultToml)
            logger.info("Created new default config file at: ${targetFile.absolutePath}")
        } catch (e: Exception) {
            logger.error("Could not create config file at ${targetFile.absolutePath}: ${e.message}")
        }

        return targetFile
    }

    fun getConfigSearchPaths(): List<File> {
        val appName = "oatmeal"
        val homeDir = System.getProperty("user.home") ?: ""
        val os = System.getProperty("os.name").lowercase()

        val paths = mutableListOf<File>()

        val xdgConfigHome = System.getenv("XDG_CONFIG_HOME")
        if (!xdgConfigHome.isNullOrEmpty()) {
            paths.add(File(xdgConfigHome, "$appName/config.toml"))
        } else if (homeDir.isNotEmpty()) {
            paths.add(File(homeDir, ".config/$appName/config.toml"))
        }

        when {
            os.contains("mac") -> {
                if (homeDir.isNotEmpty()) {
                    paths.add(File(homeDir, "Library/Application Support/$appName/config.toml"))
                }
            }
            os.contains("win") -> {
                val appData = System.getenv("APPDATA")
                if (!appData.isNullOrEmpty()) {
                    paths.add(File(appData, "$appName/config.toml"))
                }
                val localAppData = System.getenv("LOCALAPPDATA")
                if (!localAppData.isNullOrEmpty()) {
                    paths.add(File(localAppData, "$appName/config.toml"))
                }
            }
        }

        paths.add(File("config.toml"))

        return paths
    }
}
