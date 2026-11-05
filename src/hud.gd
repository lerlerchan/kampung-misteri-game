extends CanvasLayer

signal card_picked(kind: String)

const R := preload("res://src/rules.gd")

const CARD_KINDS: Array[String] = ["pisang", "kelapa", "durian"]
const CARD_X: Array[float] = [20.0, 252.0, 484.0]
const CARD_WIDTH: float = 216.0
const CARD_HEIGHT: float = 76.0
const BG := Color("#FFF1D0")
const INK := Color("#44372C")
const GREEN := Color("#397A4B")
const GOLD := Color("#F4C542")
const DISABLED := Color("#B9B2A5")

var _balance: Dictionary = {}
var _cards: Dictionary = {}
var _selected: String = ""
var _sen_label: Label
var _wave_label: Label
var _result_panel: PanelContainer
var _result_label: Label


func _ready() -> void:
	_balance = R.load_balance()
	_build_hud()


func _build_hud() -> void:
	var bar := ColorRect.new()
	bar.position = Vector2(0, 0)
	bar.size = Vector2(1280, 104)
	bar.color = Color("#F6DEAA")
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar)
	for index in CARD_KINDS.size():
		_add_card(CARD_KINDS[index], index, CARD_X[index])
	var status := PanelContainer.new()
	status.position = Vector2(954, 14)
	status.size = Vector2(306, 76)
	status.add_theme_stylebox_override("panel", _style(BG, Color("#8A5638"), 3, 14))
	add_child(status)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 3)
	status.add_child(stack)
	_sen_label = Label.new()
	_sen_label.text = "● 0 sen"
	_sen_label.add_theme_font_size_override("font_size", 23)
	_sen_label.add_theme_color_override("font_color", INK)
	stack.add_child(_centered(_sen_label))
	_wave_label = Label.new()
	_wave_label.text = "Bersedia · Gelombang 0 / 0"
	_wave_label.add_theme_font_size_override("font_size", 15)
	_wave_label.add_theme_color_override("font_color", GREEN)
	stack.add_child(_centered(_wave_label))
	_result_panel = PanelContainer.new()
	_result_panel.position = Vector2(280, 286)
	_result_panel.size = Vector2(720, 148)
	_result_panel.add_theme_stylebox_override("panel", _style(Color("#FFF1D0"), Color("#8A5638"), 5, 22))
	_result_panel.visible = false
	add_child(_result_panel)
	_result_label = Label.new()
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_result_label.add_theme_font_size_override("font_size", 42)
	_result_label.add_theme_color_override("font_color", INK)
	_result_panel.add_child(_result_label)


func _add_card(kind: String, index: int, x: float) -> void:
	var data: Dictionary = _balance.get("plants", {}).get(kind, {})
	var card := Button.new()
	card.position = Vector2(x, 14)
	card.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	card.focus_mode = Control.FOCUS_ALL
	card.add_theme_stylebox_override("normal", _style(BG, Color("#8A5638"), 2, 12))
	card.add_theme_stylebox_override("hover", _style(Color("#FFF8E8"), Color("#397A4B"), 3, 12))
	card.add_theme_stylebox_override("pressed", _style(Color("#E9F0C8"), GREEN, 3, 12))
	card.add_theme_stylebox_override("disabled", _style(Color("#E7E0D2"), DISABLED, 2, 12))
	card.add_theme_color_override("font_color", INK)
	card.add_theme_color_override("font_disabled_color", Color("#625C53"))
	card.add_theme_font_size_override("font_size", 17)
	card.text = "%d  %s\n%d sen" % [index + 1, str(data.get("name", kind.capitalize())), int(data.get("cost", 0))]
	card.pressed.connect(_on_card_pressed.bind(kind))
	add_child(card)
	_cards[kind] = card


func _centered(label: Label) -> CenterContainer:
	var center := CenterContainer.new()
	center.add_child(label)
	return center


func _style(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 10.0
	box.content_margin_right = 10.0
	box.content_margin_top = 6.0
	box.content_margin_bottom = 6.0
	return box


func _on_card_pressed(kind: String) -> void:
	select_card(kind)
	card_picked.emit(kind)


## Updates the displayed sen balance.
func set_sen(n: int) -> void:
	_sen_label.text = "● %d sen" % n


## Updates the current wave and total wave count.
func set_wave(i: int, total: int) -> void:
	_wave_label.text = "Gelombang %d / %d" % [i, total] if i > 0 else "Bersedia · Gelombang 0 / %d" % total


## Enables or disables the card for a plant kind.
func set_card_enabled(kind: String, on: bool) -> void:
	if _cards.has(kind):
		(_cards[kind] as Button).disabled = not on


## Highlights a plant card; an empty kind clears the selection.
func select_card(kind: String) -> void:
	_selected = kind if _cards.has(kind) else ""
	for card_kind: String in _cards:
		var card := _cards[card_kind] as Button
		card.add_theme_stylebox_override("normal", _style(Color("#E9F0C8"), GOLD, 5, 12) if card_kind == _selected else _style(BG, Color("#8A5638"), 2, 12))


## Shows the centered victory or defeat result banner.
func show_result(won: bool) -> void:
	_result_label.text = "Kampung selamat!" if won else "Rumah diserang!"
	_result_panel.visible = true
