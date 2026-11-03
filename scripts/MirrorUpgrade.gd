class_name MirrorUpgrade
extends Resource

## Bir kaynağı zindan ödülü olarak oluşturup Shield.apply_upgrade() ile uygula.
enum Kind { PRISM, FOCUS, AUTO_AIM, GHOST }
@export var kind: Kind = Kind.PRISM
@export_enum("3", "5") var prism_count: int = 3
