@file:JvmName("Main")
package cc.playfairs.oatmeal

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.application
import org.jetbrains.jewel.foundation.theme.JewelTheme
import org.jetbrains.jewel.intui.standalone.theme.IntUiTheme
import org.jetbrains.jewel.intui.standalone.theme.darkThemeDefinition
import org.jetbrains.jewel.intui.standalone.theme.lightThemeDefinition
import org.jetbrains.jewel.intui.standalone.theme.default
import org.jetbrains.jewel.intui.window.decoratedWindow
import org.jetbrains.jewel.intui.window.styling.dark
import org.jetbrains.jewel.intui.window.styling.light
import org.jetbrains.jewel.ui.ComponentStyling
import org.jetbrains.jewel.ui.component.Text
import org.jetbrains.jewel.window.DecoratedWindow
import org.jetbrains.jewel.window.TitleBar
import org.jetbrains.jewel.window.styling.TitleBarStyle
import cc.playfairs.oatmeal.config.AppConfig
import org.apache.logging.log4j.LogManager
import cc.playfairs.oatmeal.logging.Logger

private val setupLogDir = Logger.setupLogDir
private val logger = LogManager.getLogger()

fun main() = application {
    logger.info("Initializing compose lifetime...")

    val config = remember { AppConfig.loadConfig() }

    val isDark = config.preferences.theme == AppConfig.Theme.Dark
    val themeDefinition = if (isDark) JewelTheme.darkThemeDefinition() else JewelTheme.lightThemeDefinition()
    val titleBarStyle = if (isDark) TitleBarStyle.dark() else TitleBarStyle.light()

    IntUiTheme(
        theme = themeDefinition,
        styling = ComponentStyling.default().decoratedWindow(
            titleBarStyle = titleBarStyle
        ),
    ) {
        DecoratedWindow(
            onCloseRequest = ::exitApplication,
            title = "Oatmeal"
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .background(JewelTheme.globalColors.panelBackground)
            ) {
                TitleBar {
                    Text(
                        text = "Oatmeal",
                        modifier = Modifier.padding(start = 8.dp)
                    )
                }

                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Text("Helo")
                }
            }
        }
    }
}
