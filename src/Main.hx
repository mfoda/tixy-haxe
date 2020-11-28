package;

using StringTools;

import Math.sin;
import Math.sqrt;
import Math.pow;
import ANSI;
import haxe.Timer;

using Lambda;

class Main {
	static var matrix = new Array<Array<Float>>();
	static var parser = new hscript.Parser();
	static var interp = new hscript.Interp();
	static var code: String;
	static var println = Sys.println;

	public static function main() {
		code = Sys.args().empty() ? "sin(y/8+t)" : Sys.args()[0];

		println(ANSI.eraseDisplay());
		println(ANSI.set(Off, Green));
		println(ANSI.hideCursor());
		println(ANSI.title("T.I.X.Y"));
		for (i in 0...16) {
			matrix[i] = [];
			for (j in 0...16)
				matrix[i][j] = 0;
		}

		render();
	}

	static function render() {
		var dt = 1 / 60;
		var time = 0.;
		var characters = " .-=oO0@";
		var ast = parser.parseString(code);
		interp.variables.set("sin", Math.sin);
		interp.variables.set("cos", Math.cos);
		interp.variables.set("sqrt", Math.sqrt);
		interp.variables.set("pow", Math.pow);

		try {
			while (true) {
				var cmd = "";
				cmd += ANSI.set(Off);
				for (row in 0...matrix.length) {
					for (col in 0...matrix[row].length) {
						var index = row * matrix.length + col;
						interp.variables.set("t", time);
						interp.variables.set("i", index);
						interp.variables.set("x", col);
						interp.variables.set("y", row);
						matrix[row][col] = interp.execute(ast);
						var value = Math.min(1, Math.abs(matrix[row][col]));
						var character = characters.charAt(Math.floor(value * characters.length));
						cmd += ANSI.setXY(col, row);
						cmd += "\x1b[31m" + character;
					}
					cmd += "\n";
				}
				Sys.stdout().writeString(cmd);
				println(ANSI.set(Green, Bold) + code + ANSI.set(BoldOff));
				time += dt;
				Sys.sleep(dt);
			}
		} catch (e) {
			trace('${e.details}');
		}
	}
}
