import glob
from pathlib import Path
from ufoLib2 import Font

SOURCE = Path("/tmp")

for file in SOURCE.glob("*.ufo"):
	print ("Processing",file)
	font = Font.open(file)
	font.renameGlyph("cid00000",".notdef")

	font.info.openTypeVheaVertTypoAscender = 500
	font.info.openTypeVheaVertTypoDescender = -500
	font.info.openTypeVheaVertTypoLineGap = 500
	font.info.openTypeNameDesigner = "Ryoko NISHIZUKA 西塚涼子 (kana, bopomofo & ideographs); Paul D. Hunt (Latin, Greek & Cyrillic); Sandoll Communications 산돌커뮤니케이션, Soo-young JANG 장수영 & Joo-yeon KANG 강주연 (hangul elements, letters & syllables); Tamcy (Chinese glyphs modifications & additions)"

	for glyph in font:
		glyph.height = 1000

	font.save(file,overwrite=True)