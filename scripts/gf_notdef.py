import glob
from pathlib import Path
from ufoLib2 import Font

SOURCE = Path("/tmp")

for file in SOURCE.glob("*.ufo"):
	print ("Processing",file)
	font = Font.open(file)
	try:
		font.renameGlyph("cid00000",".notdef")
		font.renameGlyph("cid41644","uni00A0")
		font.renameGlyph("cid41639","space")
	except:
		print("*** NOTDEF RENAME FAILED ***")

	font.save(file,overwrite=True)