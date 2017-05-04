;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; HELP and VIEW-INFO
;;;; Last updated: 05/04/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 1:TEXT:!help*:*: { $gamehelp($2, $nick) }
alias gamehelp { 
  set %help.topics $readini %help_folder $+ topics.help Help List | set %help.topics2 $readini %help_folder $+ topics.help Help List2 | set %help.topics3 $readini %help_folder $+ topics.help Help List3
  if ($1 = $null) { $display.private.message2($2, 14::[Current Help Topics]::) |  $display.private.message2($2,2 $+ %help.topics) | $display.private.message2($2,2 $+ %help.topics2) | unset %help.topics | unset %help.topics2 | $display.private.message2($2, 14::[Type !help <topic> (without the <>) to view the topic]::) | halt }

  if ($isfile(%help_folder $+ $1 $+ .help) = $true) {  set %topic %help_folder $+ $1 $+ .help |  set %lines $lines(%topic) | set %l 0 | goto help }
  else { $display.private.message2($2, 3The Librarian searchs through the ancient texts but returns with no results for your inquery!  Please try again) | halt }
  :help
  inc %l 1
  if (%l <= %lines) {  
    if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { 
      var %timer.delay.help $calc(%l - 1)
      var %line.to.send $read(%topic, %l)
      if (%line.to.send != $null) { $display.private.message.delay.custom(%line.to.send, %timer.delay.help, $2) }
    }
    if ($readini(system.dat, system, botType) = DCCchat) { $display.private.message($read(%topic, %l))  }
    goto help
  }
  else { goto endhelp }
  :endhelp
  unset %help.topics3 |  unset %topic | unset %help.topics | unset %help.topics2 | unset %lines | unset %l | unset %help
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The view-info command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 1:TEXT:!view-info*:*: { $view-info($nick, $2, $3, $4) }
alias view-info {
  if ($2 = $null) { var %error.message 4Error: The command is missing what you want to view.  Use it like:  !view-info <adventure $+ $chr(44) ability $+ $chr(44) item $+ $chr(44) weapon, armor, shield> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }
  if ($3 = $null) { var %error.message 4Error: The command is missing the name of what you want to view.   Use it like:  !view-info <adventure, ability, item, weapon, armor, shield> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }

  if ($2 = weapon ) {
    if ($readini($dbfile(weapons.db), $3, type) = $null) { $display.private.message(4Invalid weapon) | halt }
    if ($readini($dbfile(weapons.db), $3, type) = shield) { $display.private.message(4Invalid weapon Use 12!view-info shield $3 4to see info on this) | halt }

    var %info.type $readini($dbfile(weapons.db), $3, type) |  var %info.jobs $readini($dbfile(weapons.db), $3, jobs) 
    var %info.stat $readini($dbfile(weapons.db), $3, stat) |  var %info.damage $readini($dbfile(weapons.db), $3, damage) 
    var %info.speed $readini($dbfile(weapons.db), $3, speed) | var %info.element $readini($dbfile(weapons.db), $3, Element) 
    var %info.minlevel [4Minimum Job Level to Equip12 $readini($dbfile(weapons.db), $3, PlayerLevel) $+ ]
    var %info.wpnlevel [4Weapon iLevel12 $readini($dbfile(weapons.db), $3, ItemLevel) $+ ]
    var %info.cost $readini($dbfile(weapons.db), $3, cost)
    if (%info.cost = $null) { var %info.cost 0 }

    var %info.sellprice $readini($dbfile(weapons.db), $3, sellPrice)
    if (%info.sellprice = $null) { var %info.sellprice 0 }

    if ($readini($dbfile(weapons.db), $3, AmmoRequired) != $null) {
      var %info.ammo [4Ammo Required12 $readini($dbfile(weapons.db), $3, AmmoRequired) $+ ] [4Ammo Consumed12 $readini($dbfile(weapons.db), $3, AmmoAmountNeeded) $+ ] 
    }

    $display.private.message([4Name12 $rarity.color.check($3, weapon) $+ $3 $+ ] [4Weapon Type12 %info.type $+ ] [4Weapon Speed12 %info.speed $+ ] [4Jobs that can equip12 %info.jobs $+ ] %info.minlevel %info.wpnlevel [4Element of Weapon12 %info.element $+ ] %info.ammo) 
    $display.private.message([4Weapon Damage12 %info.damage $+ ][4Cost12 $iif(%info.cost > 0, %info.cost $currency, cannot be purchased in a shop) $+ ] [4Sell Price12 $iif(%info.sellprice > 0, %info.sellprice $currency, cannot be sold to a shop) $+ ]) 
    $display.private.message([4Stat Bonuses] [4STR12 $chr(43) $+ $readini($dbfile(weapons.db), $3, str) $+ ] [4DEX12 $chr(043) $+ $readini($dbfile(weapons.db), $3, dex) $+ ] [4VIT12 $chr(043) $+ $readini($dbfile(weapons.db), $3, vit) $+ ] [4INT12 $chr(043) $+ $readini($dbfile(weapons.db), $3, int) $+ ] [4MND12 $chr(043) $+ $readini($dbfile(weapons.db), $3, mnd) $+ ] [4PIE12 $chr(043) $+ $readini($dbfile(weapons.db), $3, pie) $+ ] [4Physical Defense12 $chr(043) $+ $readini($dbfile(weapons.db), $3, pDefense) $+ ] [4Magical Defense12 $chr(043) $+ $readini($dbfile(weapons.db), $3, mDefense) $+ ]) 
    $display.private.message([4Weapon Description12 $readini($dbfile(weapons.db), $3, Info) $+ ])
  }


  if ($2 = ability) { $display.private.message(To Be Added) } 

  if ($2 = item) { $display.private.message(To Be Added) } 

  if (($2 = armor) || ($2 = shield)) {

    var %info.name $readini($dbfile(equipment.db), $3, name) 
    var %info.name $rarity.color.check($3, armor) $+ %info.name
    var %info.type $readini($dbfile(equipment.db), $3, EquipLocation) 

    var %info.jobs $readini($dbfile(equipment.db), $3, jobs) 
    if (%info.jobs != $null) { var %info.jobs $clean.list(%info.jobs) } 
    if (%info.jobs = $null) { var %info.jobs any }

    var %info.minlevel [4Minimum Job Level to Equip12 $readini($dbfile(equipment.db), $3, PlayerLevel) $+ ]
    var %info.armorlevel [4 $+ $2 iLevel12 $readini($dbfile(equipment.db), $3, ItemLevel) $+ ]

    var %info.cost $readini($dbfile(equipment.db), $3, cost)
    if (%info.cost = $null) { var %info.cost 0 }

    var %info.sellprice $readini($dbfile(equipment.db), $3, sellPrice)
    if (%info.sellprice = $null) { var %info.sellprice 0 }

    $display.private.message([4Name12 %info.name $+ ] [4Type12 %info.type $+ ] [4Jobs that can equip12 %info.jobs $+ ] %info.minlevel %info.armorlevel)
    $display.private.message([4Cost12 $iif(%info.cost > 0, %info.cost $currency, cannot be purchased in a shop) $+ ] [4Sell Price12 $iif(%info.sellprice > 0, %info.sellprice $currency, cannot be sold to a shop) $+ ])
    $display.private.message([4Stat Bonuses] [4STR12 $chr(43) $+ $readini($dbfile(equipment.db), $3, str) $+ ] [4DEX12 $chr(043) $+ $readini($dbfile(equipment.db), $3, dex) $+ ] [4VIT12 $chr(043) $+ $readini($dbfile(equipment.db), $3, vit) $+ ] [4INT12 $chr(043) $+ $readini($dbfile(equipment.db), $3, int) $+ ] [4MND12 $chr(043) $+ $readini($dbfile(equipment.db), $3, mnd) $+ ] [4PIE12 $chr(043) $+ $readini($dbfile(equipment.db), $3, pie) $+ ] [4Physical Defense12 $chr(043) $+ $readini($dbfile(equipment.db), $3, pDefense) $+ ] [4Magical Defense12 $chr(043) $+ $readini($dbfile(equipment.db), $3, mDefense) $+ ]) 
  }


  if ($2 = adventure) { 
    if (($isfile($zonefile($3)) = $false) || ($3 = template)) { $display.private.message(4No such adventure exists) | halt }

    var %info.name $readini($zonefile($3), Info, Name) | var %info.levelrange $readini($zonefile($3), Info, LevelRange)
    var %info.ilevel $readini($zonefile($3), Info, iLevel)
    if (%info.ilevel = $null) { var %info.ilevel 1 }
    var %info.prereq $readini($zonefile($3), Info, PreReq)
    if (%info.prereq != $null) { var %info.prereq [4Pre-requirement12 $readini($zonefile(%info.prereq), Info, Name) $+ ] }
    if (%info.prereq = $null) { var %info.prereq [4Pre-requirement12 none] }
    var %info.roomcount $calc($ini($zonefile($3),0) - 1)
    var %info.partyactions $readini($zonefile($3), Info, AdventureActions)

    $display.private.message([4Adventure Name12 %info.name $+ ] [4Level Range12 %info.levelrange $+ ] [4Minimium iLevel to Enter12 %info.ilevel $+ ] %info.prereq)
    $display.private.message([4Number of Rooms12 %info.roomcount  $+ ]  [4Starting Party Stamina12 %info.partyactions $+ ])
  }

}
