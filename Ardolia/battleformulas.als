;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; battleformulas.als
;;;; Last updated: 04/28/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determines the damage
; display color
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
damage.color.check {
  if (%starting.damage > %attack.damage) { set %damage.display.color 6 }
  if (%starting.damage < %attack.damage) { set %damage.display.color 7 }
  if (%starting.damage = %attack.damage) { set %damage.display.color 4 }

  unset %starting.damage
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Goes through the modifiers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
damage.modifiers.check {
  ; $1 = the user
  ; $2 = the weapon or tech name
  ; $3 = the target
  ; $4 = melee or tech

  ;;;;;;;;;;;;;; All attacks check the weapon itself

  ; Check to see if the target is resistant/weak to the weapon itself

  $modifer_adjust($3, $readini($char($1), weapons, equipped))

  ; Check for Left-Hand weapon, if applicable
  if ($readini($char($1), equipped, weapon2) != nothing) { 
    var %weapon.type2 $readini($dbfile(weapons.db), $readini($char($1), equipment, weapon2), type)
    if (%weapon.type2 != shield) { $modifer_adjust($3, $readini($char($1), equipment, weapon2))  }
  }


  ;;;;;;;;;;;;;; Melee checks: weapon element and weapon type
  if ($4 = melee) { 

    var %weapon.element $readini($dbfile(weapons.db), $2, element)
    if ((%weapon.element != $null) && (%weapon.element != none)) {  $modifer_adjust($3, %weapon.element)  }

    ; Check for Left-Hand weapon element, if applicable
    if ((%weapon.type2 != $null) && (%weapon.type2 != shield)) { 
      var %weapon.element2 $readini($dbfile(weapons.db), $readini($char($1), weapons, EquippedLeft), Element )
      $modifer_adjust($3, %weapon.element2) 
    }

    ; Check for weapon type weaknesses.
    var %weapon.type $readini($dbfile(weapons.db), $2, type)
    $modifer_adjust($3, %weapon.type)

    ; Elementals are strong to melee
    if ($readini($char($3), monster, type) = elemental) { %attack.damage = $round($calc(%attack.damage - (%attack.damage * .30)),0) } 
  }

  ;;;;;;;;;;;;;; Techs check: tech name, tech element
  if ($4 = tech) { 

    ; Check for the tech name
    ; if $2 = element, use +techname, else use techname
    var %elements fire.earth.wind.water.ice.lightning.light.dark
    if ($istok(%elements, $2, 46) = $true) { $modifer_adjust($3, $chr(43) $+ $2) }
    else { $modifer_adjust($3, $2) }

    ; Check for the tech element
    var %tech.element $readini($dbfile(techniques.db), $2, element)

    if ((%tech.element != $null) && (%tech.element != none)) {
      if ($numtok(%tech.element,46) = 1) { $modifer_adjust($3, %tech.element) }
      if ($numtok(%tech.element,46) > 1) { 
        var %element.number 1 
        while (%element.number <= $numtok(%tech.element,46)) {
          var %current.tech.element $gettok(%tech.element, %element.number, 46)
          $modifer_adjust($3, %current.tech.element)
          inc %element.number 
        }
      } 
    }
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Modifier Checks for
; elements and weapon types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
modifer_adjust {
  ; $1 = target
  ; $2 = element or weapon type

  if (%guard.message != $null) { return }

  ; Let's get the adjust value.
  var %modifier.adjust.value $readini($char($1), modifiers, $2)
  if (%modifier.adjust.value = $null) { var %modifier.adjust.value 100 }

  ; Check for accessories that cut elemental damage down.
  set %elements earth.fire.wind.water.ice.lightning.light.dark
  if ($istok(%elements,$2,46) = $true) {   
    if ($accessory.check($1, ElementalDefense) = true) {
      if (%accessory.amount = 0) { var %accessory.amount .50 }
      %modifier.adjust.value = $round($calc(%modifier.adjust.value * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for augment to cut elemental damage down
    if ($augment.check($1, EnhanceElementalDefense) = true) { dec %modifier.adjust.value $calc(%augment.strength * 10) } 

    unset %current.accessory | unset %current.accessory.type | unset %accessory.amount
  }
  unset %elements

  ; Turn it into a deciminal
  var %modifier.adjust.value $calc(%modifier.adjust.value / 100) 

  if (($readini($char($1), info, flag) != $null) && ($readini($char($1), info, clone) != yes)) {
    ; If it's over 1, then it means the target is weak to the element/weapon so we can adjust the target's def a little as an extra bonus.
    if (%modifier.adjust.value > 1) {
      var %mon.temp.def $readini($char($1), battle, def)
      var %mon.temp.def = $round($calc(%mon.temp.def - (%mon.temp.def * .05)),0)
      if (%mon.temp.def < 0) { var %mon.temp.def 0 }
      writeini $char($1) battle def %mon.temp.def
      set %damage.display.color 7
    }

    ; If it's under 1, it means the target is resistant to the element/weapon.  Let's make the monster stronger for using something it's resistant to.

    if (%modifier.adjust.value < 1) {
      var %mon.temp.str $readini($char($1), battle, str)
      var %mon.temp.str = $round($calc(%mon.temp.str + (%mon.temp.str * .05)),0)
      if (%mon.temp.str < 0) { var %mon.temp.str 0 }
      writeini $char($1) battle str %mon.temp.str
      set %damage.display.color 6
    }
  }

  ; Adjust the attack damage.
  set %attack.damage $round($calc(%attack.damage * %modifier.adjust.value),0)
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates the evasion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.evasion { 
  ; $1 = the person we need the evasion for
  ; $2 = the target 

  var %evasion 0

  var %evasion $roll(2d6)

  if ($get.level($1) < $get.level($2)) { var %evasion $roll(1d6) }

  inc %evasion $current.dex($2)

  return %evasion
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates accuracy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.accuracy {
  ; $1 = the person we need the accuracy for
  ; $2 = the target
  ; $3 = melee or spell

  var %accuracy $roll(2d6)

  if ($get.level($1) < $get.level($2)) { var %accuracy $roll(1d6) }

  if ($3 = melee) {
    inc %accuracy $round($calc($current.dex($1) /2),0)
  }

  if ($3 = spell) { 
    inc %accuracy $current.pie($1)
  }

  return %accuracy
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates weapon power
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.wpn.damage {
  ; $1 = the person we're checking

  var %weapon.damage $weapon.damage($1)
  var %weapon.speed $weapon.speed($1)
  var %current.str $current.str($1)
  var %current.det $current.det($1)

  var %base.melee.damage $abs($calc((%weapon.damage *.2714745 + %current.str *.1006032 + (%current.det -202)*.0241327 + %weapon.damage * %current.str *.0036167 + %weapon.damage * (%weapon.det - 202)*.0022597 - 1) * (%weapon.speed / 3)))
  inc %base.melee.damage $rand(1,2)

  return $round(%base.melee.damage,0)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates defense
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.defense {
  ; $1 = the person
  ; $2 = physical or magical

  var %defense.percent 100


  if ($2 = physical) { var %defense $current.defense($1) }

  if ($2 = spell) { var %defense $current.mdefense($1) }


  var %defense.percent $abs($calc(1 - (0.044 * %defense)))
  echo -a defense: %defense
  echo -a percent: %defense.percent

  if (%defense.percent = 1) { return 1 }
  else { 

    var %defense.percent $calc((100-%defense.percent)/100)


    return %defense.percent
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Melee Formula for Players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.melee.player {
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 

  set %attack.damage $calculate.wpn.damage($1)
  var %damage.defense.percent $calculate.defense($3, physical)

  set %attack.damage $floor($calc(%attack.damage * %damage.defense.percent))
  if (%attack.damage <= 0) { set %attack.damage 1 }

  ; Check for modifiers
  set %starting.damage %attack.damage
  $damage.color.check
  ; to be added
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Melee Formula for Monsters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.melee.monster {
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 

  set %attack.damage $calculate.wpn.damage($1)
  var %damage.defense.percent $calculate.defense($3, physical)

  set %attack.damage $floor($calc(%attack.damage * %damage.defense.percent))
  if (%attack.damage <= 0) { set %attack.damage 1 }

  ; Check for modifiers
  set %starting.damage %attack.damage
  $damage.color.check
  ; to be added

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Attack Ability Formula for Players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.ability.player {

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Attack Ability Formula for Monsterss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.ability.monster {

}
