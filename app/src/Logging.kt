package cc.playfairs.oatmeal.logging

import java.io.File

object Logger {
    val setupLogDir: Unit = run {
        val appName = "oatmeal"
        val homeDir = System.getProperty("user.home") ?: ""
        val os = System.getProperty("os.name").lowercase()

        val logDir = when {
            os.contains("mac") -> File(homeDir, "Library/Logs/$appName")
            os.contains("win") -> {
                val localAppData = System.getenv("LOCALAPPDATA")
                if (!localAppData.isNullOrEmpty()) File(localAppData, "$appName/logs")
                else File(homeDir, "AppData/Local/$appName/logs")
            }
            else -> {
                val xdgState = System.getenv("XDG_STATE_HOME")
                if (!xdgState.isNullOrEmpty()) File(xdgState, "$appName/logs")
                else File(homeDir, ".local/state/$appName/logs")
            }
        }

        logDir.mkdirs()
        System.setProperty("log.dir", logDir.absolutePath)
    }
}
