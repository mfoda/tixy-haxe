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
		// "sin(y/8+t*4)"
		code = "sin(t-sqrt(pow((x-7.5),2)+pow((y-6),2)))";
		code = Sys.args().empty() ? code : Sys.args()[0];

		println(ANSI.eraseDisplay());
		println(ANSI.set(Off));
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
		var dt = 1 / 30;
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
						var color = Red;
						var value = matrix[row][col];
						if (value < 0 ) {
							value = -value;
							color = White;
						}
						if (value > 1)
							value = 1;

						var character = characters.charAt(Math.floor(value * characters.length));
						cmd += ANSI.setXY(col + col*2 + 4, row + Std.int(row/16) + 2);
						cmd += ANSI.aset([Bold, color]) + character;
					}
					cmd += "\n";
				}
				Sys.stdout().writeString(cmd);
				println(ANSI.set(White, Bold) + "\n\n(t,i,x,y) -> " + code + ANSI.set(BoldOff));
				time += dt;
				Sys.sleep(dt);
			}
		} catch (e) {
			trace('${e.details}');
		}
	}
}
