@file:JvmName("Main") // Remove `Kt` suffix mess for this file
package cc.playfairs.oatmeal

class App {
    val greeting: String
        get() {
            return "Hello World!"
        }
}

fun main() {
    println(App().greeting)
}
