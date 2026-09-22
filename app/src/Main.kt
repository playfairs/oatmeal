@file:JvmName("Main") // Remove `Kt` suffix mess for this file
package cc.playfairs.oatmeal

import androidx.compose.foundation.layout.*
import androidx.compose.material.Button
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application

fun main() = application {
    Window(onCloseRequest = ::exitApplication, title = "Oatmeal") {
        MaterialTheme {
            var count by remember { mutableStateOf(0) }
            Column(
                modifier = Modifier.fillMaxSize().padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Text("Hello, Compose Desktop!")
                Spacer(Modifier.height(16.dp))
                Text("Count: $count")
                Spacer(Modifier.height(16.dp))
                Button(onClick = { count++ }) { Text("Increment") }
            }
        }
    }
}
