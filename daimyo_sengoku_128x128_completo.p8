pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- =========================================================
-- sengoku 128x128
-- mini strategico a turni per pico-8
--
-- obiettivo:
-- conquistare higo prima del 1572.
--
-- sconfitta:
-- satsuma viene conquistata
-- oppure arriva il 1572 senza vittoria.
--
-- controlli:
-- mappa:
--   < > seleziona
--   a entra
--
-- provincia:
--   < > cambia comando
--   a esegue
--   b mappa
--   u daimyo
--   d situazione
--
-- situazione:
--   a cambia diplomazia
--   u esercito
--   d consiglio
--   b indietro
--
-- le altre schermate:
--   b indietro
--
-- la sprite sheet resta riservata
-- alla mappa importata.
-- =========================================================


-- =========================================================
-- stato generale
-- =========================================================

selected=1
screen="map"

turn=1
year=1560
season=1

-- 1 primavera
-- 2 estate
-- 3 autunno
-- 4 inverno

player_clan="shimazu"

relations=2
-- 1 pace
-- 2 tensione

gameover=false
win=false

logmsg="anno 1560: primavera"


-- =========================================================
-- province
-- =========================================================

provinces={
 {
  name="satsuma",
  short="satsu",
  x=74,y=42,

  clan="shimazu",
  daimyo="shimazu",

  rice=70,
  gold=50,
  soldiers=60,

  morale=70,
  development=62,
  fort=55,

  color=8,
  owner=1
 },

 {
  name="higo",
  short="higo",
  x=57,y=69,

  clan="kato",
  daimyo="kato",

  rice=50,
  gold=70,
  soldiers=50,

  morale=62,
  development=58,
  fort=48,

  color=11,
  owner=2
 }
}


-- =========================================================
-- comandi
-- =========================================================

actions={
 "riso",
 "oro",
 "recluta",
 "forte",
 "sviluppa",
 "attacca"
}

selected_action=1


-- =========================================================
-- init
-- =========================================================

function _init()

 selected=1
 screen="map"

 turn=1
 year=1560
 season=1

 relations=2

 gameover=false
 win=false

 selected_action=1

 logmsg="anno 1560: primavera"

end


-- =========================================================
-- update
-- =========================================================

function _update()

 if gameover then

  if btnp(4) then
   _init()
  end

  return
 end


 -- =======================================================
 -- mappa
 -- =======================================================

 if screen=="map" then

  if btnp(0) then
   selected-=1

   if selected<1 then
    selected=#provinces
   end
  end

  if btnp(1) then
   selected+=1

   if selected>#provinces then
    selected=1
   end
  end

  if btnp(4) then
   screen="province"
  end

  if btnp(5) then
   screen="status"
  end


 -- =======================================================
 -- provincia
 -- =======================================================

 elseif screen=="province" then

  if btnp(0) then

   selected_action-=1

   if selected_action<1 then
    selected_action=#actions
   end

  end

  if btnp(1) then

   selected_action+=1

   if selected_action>#actions then
    selected_action=1
   end

  end

  if btnp(4) then

   do_action(actions[selected_action])

  end

  if btnp(5) then
   screen="map"
  end

  if btnp(2) then
   screen="daimyo"
  end

  if btnp(3) then
   screen="status"
  end


 -- =======================================================
 -- daimyo
 -- =======================================================

 elseif screen=="daimyo" then

  if btnp(5) then
   screen="province"
  end


 -- =======================================================
 -- situazione
 -- =======================================================

 elseif screen=="status" then

  if btnp(4) then

   if relations==1 then

    relations=2
    logmsg="tensione: guerra possibile"

   else

    relations=1
    logmsg="pace: commercio aperto"

   end

  end

  if btnp(2) then
   screen="army"
  end

  if btnp(3) then
   screen="council"
  end

  if btnp(5) then
   screen="province"
  end


 -- =======================================================
 -- esercito
 -- =======================================================

 elseif screen=="army" then

  if btnp(5) then
   screen="status"
  end


 -- =======================================================
 -- consiglio
 -- =======================================================

 elseif screen=="council" then

  if btnp(5) then
   screen="status"
  end

 end

end


-- =========================================================
-- draw
-- =========================================================

function _draw()

 cls()

 if gameover then

  draw_end()

  return
 end


 local p=provinces[selected]

 if screen=="map" then

  draw_map(p)

 elseif screen=="province" then

  draw_province(p)

 elseif screen=="daimyo" then

  draw_daimyo_screen(p)

 elseif screen=="status" then

  draw_status(p)

 elseif screen=="army" then

  draw_army(p)

 elseif screen=="council" then

  draw_council(p)

 end

end


-- =========================================================
-- mappa
-- =========================================================

function draw_map(p)

 -- sprite sheet / mappa importata
 sspr(0,0,128,128)

 -- evidenzia provincia
 fill_province(p.x,p.y,8)

 local r=4+flr(time()*4)%2

 circ(p.x,p.y,r,12)
 circ(p.x,p.y,2,7)


 -- titolo
 rectfill(2,2,87,12,0)

 print("sengoku "..year,5,4,7)


 -- controlli
 rectfill(2,114,87,126,0)

 print("< > seleziona",5,115,6)
 print("a: provincia",5,122,7)


 -- pannello
 rectfill(89,0,127,127,0)
 rect(89,0,127,127,7)

 print("prov.",93,4,6)
 print(p.short,93,10,7)

 line(92,18,124,18,5)

 print("clan",93,22,6)
 print(p.clan,93,28,7)

 print("owner",93,39,6)

 if p.owner==1 then
  print("tu",93,45,11)
 else
  print("avv",93,45,8)
 end

 print("riso",93,58,6)
 draw_bar(93,64,p.rice,29)

 print("oro",93,76,6)
 draw_bar(93,82,p.gold,29)

 print("arm",93,94,6)
 draw_bar(93,100,p.soldiers,29)

 print("t"..turn,93,113,6)

 draw_map_fx(p)

end


-- =========================================================
-- mappa fx
-- =========================================================

function draw_map_fx(p)

 local t=flr(time()*8)

 for i=0,3 do

  if ((t+i*3)%10)<5 then

   if i==0 then
    line(p.x+7,p.y,p.x+10,p.y,10)
   end

   if i==1 then
    line(p.x-7,p.y,p.x-10,p.y,10)
   end

   if i==2 then
    line(p.x,p.y+7,p.x,p.y+10,10)
   end

   if i==3 then
    line(p.x,p.y-7,p.x,p.y-10,10)
   end

  end

 end


 for i=0,5 do

  local x=7+((i*17+t)%78)
  local y=108+flr(sin((x+t)/10)*2)

  pset(x,y,6)

 end

end


-- =========================================================
-- provincia
-- =========================================================

function draw_province(p)

 draw_panel_bg()

 print("dominio: "..p.short,8,6,7)

 print(
  "t"..turn.." "..season_name(),
 83,6,6
 )

 line(8,14,119,14,5)


 draw_daimyo_portrait(
  p.daimyo,
 9,19,
 0.72
 )


 print("clan",52,20,6)
 print(p.clan,52,26,7)

 print("daimyo",52,36,6)
 print(p.daimyo,52,42,7)


 print("r",52,52,6)
 draw_bar(61,51,p.rice,54)

 print("o",52,62,6)
 draw_bar(61,61,p.gold,54)

 print("a",52,72,6)
 draw_bar(61,71,p.soldiers,54)

 print("m",52,82,6)
 draw_bar(61,81,p.morale,54)


 -- sviluppo piccolo indicatore
 print("sv",52,89,6)
 draw_bar(67,88,p.development,48)


 -- menu
 rectfill(50,101,119,110,1)
 rect(50,101,119,110,5)

 print("< "..actions[selected_action].." >",50,100,7)


 print("a=esegui b=map",36,114,6)
 print("u=daimyo d=stato",24,120,6)

end


-- =========================================================
-- daimyo
-- =========================================================

function draw_daimyo_screen(p)

 draw_panel_bg()

 print("il daimyo",8,6,7)
 print(p.daimyo,85,6,6)

 line(8,14,119,14,5)


 draw_daimyo_portrait(
  p.daimyo,
 8,20,
 0.9
 )


 rectfill(55,20,119,91,1)
 rect(55,20,119,91,7)


 print("signore",59,25,6)
 print(p.daimyo,59,32,7)

 print("clan",59,42,6)
 print(p.clan,59,49,7)

 line(59,55,115,55,5)

 print("morale",59,61,6)
 draw_bar(59,68,p.morale,54)

 print("fortezza",59,76,6)
 draw_bar(59,83,p.fort,54)

 draw_seal(
 103,
 37,
  p.daimyo
 )

 print("b=indietro",45,112,6)
 print("ritratto",48,119,5)

end


-- =========================================================
-- situazione
-- =========================================================

function draw_status(p)

 draw_panel_bg()

 print("situazione",8,6,7)
 print("t"..turn,109,6,6)

 line(8,14,119,14,5)


 local q=provinces[3-selected]


 -- giocatore
 print("tu",8,21,11)
 print(p.clan,8,28,7)

 print("r "..p.rice,8,37,6)
 print("o "..p.gold,8,44,6)
 print("arm "..p.soldiers,8,51,6)


 -- avversario
 print("avv",68,21,8)
 print(q.clan,68,28,7)

 print("r "..q.rice,68,37,6)
 print("o "..q.gold,68,44,6)
 print("arm "..q.soldiers,68,51,6)


 -- confronto
 draw_candle_chart(
 10,
 58,
  p.soldiers,
  q.soldiers
 )


 -- diplomazia
 rectfill(72,58,119,88,1)
 rect(72,58,119,88,5)

 print("diplo",77,62,6)

 if relations==1 then

  print("pace",84,70,11)
  print("scambio",78,78,6)

 else

  print("tens.",84,70,9)
  print("guerra",79,78,6)

 end


 print("a=cambia",78,92,5)

 -- obiettivo
 rectfill(8,97,119,108,0)

 if provinces[2].owner==1 then
  print("higo conquistata!",22,101,11)
 else
  print("obiettivo: conquista higo",15,101,7)
 end

 print("u=esercito d=consiglio",20,116,6)

end


-- =========================================================
-- esercito
-- =========================================================

function draw_army(p)

 draw_panel_bg()

 print("esercito",8,6,7)
 print(p.clan,89,6,6)

 line(8,14,119,14,5)


 print("truppe",10,22,6)
 print(p.soldiers,10,29,11)

 draw_bar(
 10,
 37,
  p.soldiers,
 105
 )


 print("morale",10,49,6)
 print(p.morale,95,49,7)

 draw_bar(
 10,
 56,
  p.morale,
 105
 )


 print("fortezza",10,68,6)
 print(p.fort,95,68,7)

 draw_bar(
 10,
 75,
  p.fort,
 105
 )


 -- consigli militari
 rectfill(10,88,117,108,1)
 rect(10,88,117,108,5)

 if p.soldiers>provinces[3-selected].soldiers then

  print("vantaggio militare",19,93,11)
  print("puoi attaccare",25,101,6)

 else

  print("forza insufficiente",19,93,8)
  print("recluta prima",29,101,6)

 end


 print("b=indietro",46,117,6)

end


-- =========================================================
-- consiglio
-- =========================================================

function draw_council(p)

 draw_panel_bg()

 print("il consiglio",8,6,7)
 print("t"..turn,109,6,6)

 line(8,14,119,14,5)


 -- economia
 rectfill(8,21,59,55,1)
 rect(8,21,59,55,5)

 print("economia",13,26,6)

 print("riso",13,35,6)
 print(p.rice,42,35,7)

 print("oro",13,44,6)
 print(p.gold,42,44,7)

 print("svil",13,53,6)
 print(p.development,42,53,7)


 -- consiglio
 rectfill(65,21,119,55,1)
 rect(65,21,119,55,5)

 print("consiglio",70,26,6)

 if p.rice<30 then

  print("manca riso",70,36,8)

 elseif p.gold<25 then

  print("manca oro",70,36,8)

 elseif p.soldiers<40 then

  print("esercito",70,36,8)
  print("debole",70,44,8)

 else

  print("dominio",70,36,11)
  print("stabile",70,44,11)

 end


 -- obiettivo
 rectfill(8,62,119,91,1)
 rect(8,62,119,91,5)

 print("missione",13,67,6)

 if provinces[2].owner==1 then

  print("higo e' tua",13,76,11)
  print("vittoria vicina",13,84,7)

 else

  print("conquista higo",13,76,7)
  print("prima del 1572",13,84,8)

 end


 -- calendario
 rectfill(8,96,119,108,0)

 print(
  "anno "..year.." "..season_name(),
 27,100,7
 )


 print("b=indietro",46,117,6)

end


-- =========================================================
-- schermata fine
-- =========================================================

function draw_end()

 rectfill(0,0,127,127,0)

 rect(5,5,122,122,7)
 rect(8,8,119,119,5)


 if win then

  print("vittoria",40,22,11)

  line(20,34,107,34,5)

  print("il tuo clan",31,46,7)
  print("domina higo",29,56,11)

  print("il periodo sengoku",19,72,6)
  print("ha un nuovo signore.",17,81,6)

  print("a = nuova partita",31,104,7)

 else

  print("sconfitta",37,22,8)

  line(20,34,107,34,5)

  print("il tuo dominio",27,46,7)
  print("e' caduto.",38,56,8)

  print("il clan shimazu",28,72,6)
  print("ha perso il controllo.",16,81,6)

  print("a = nuova partita",31,104,7)

 end

end


-- =========================================================
-- esecuzione comandi
-- =========================================================

function do_action(a)

 local p=provinces[selected]

 -- non puoi comandare il nemico
 if p.owner!=1 then

  logmsg="non controlli questa provincia"
  screen="province"

  return
 end


 if a=="riso" then

  if p.gold>=5 then

   p.rice=min(
    100,
    p.rice+8
   )

   p.gold=max(
    0,
    p.gold-5
   )

   logmsg=p.short.." produce riso"

  else

   logmsg="oro insufficiente"

   return

  end


 elseif a=="oro" then

  if p.rice>=4 then

   p.gold=min(
    100,
    p.gold+8
   )

   p.rice=max(
    0,
    p.rice-4
   )

   logmsg=p.short.." produce oro"

  else

   logmsg="riso insufficiente"

   return

  end


 elseif a=="recluta" then

  local cost=10

  if p.rice>=cost then

   p.rice-=cost

   p.soldiers=min(
    100,
    p.soldiers+10
   )

   p.morale=max(
    0,
    p.morale-2
   )

   logmsg="nuove truppe reclutate"

  else

   logmsg="riso insufficiente"

   return

  end


 elseif a=="forte" then

  if p.gold>=12 then

   p.gold-=12

   p.fort=min(
    100,
    p.fort+8
   )

   logmsg="fortificazioni migliorate"

  else

   logmsg="oro insufficiente"

   return

  end


 elseif a=="sviluppa" then

  if p.gold>=15 and p.rice>=5 then

   p.gold-=15
   p.rice-=5

   p.development=min(
    100,
    p.development+8
   )

   logmsg="provincia sviluppata"

  else

   logmsg="risorse insufficienti"

   return

  end


 elseif a=="attacca" then

  if relations==1 then

   logmsg="la pace impedisce la guerra"

   return

  end

  local enemy=provinces[3-selected]

  if enemy.owner==1 then

   logmsg="non puoi attaccare un alleato"

   return

  end


  battle(p,enemy)

  if gameover then
   return
  end

 end


 -- un'azione completata consuma il turno
 advance_turn()

 if not gameover then

  -- turno dell'ia
  enemy_turn()

 end

end


-- =========================================================
-- battaglia
-- =========================================================

function battle(p,e)

 local player_power=
  p.soldiers+
  flr(p.morale/2)+
  flr(p.development/4)

 local enemy_power=
  e.soldiers+
  flr(e.morale/2)+
  flr(e.fort/3)


 -- piccolo elemento casuale
 player_power+=flr(rnd(10))
 enemy_power+=flr(rnd(10))


 if player_power>enemy_power then

  p.soldiers=max(
   0,
   p.soldiers-flr(e.soldiers/5)-5
  )

  e.soldiers=max(
   0,
   e.soldiers-flr(p.soldiers/3)-12
  )

  p.morale=min(
   100,
   p.morale+8
  )

  e.morale=max(
   0,
   e.morale-12
  )

  -- conquista
  if e.soldiers<=10 then

   e.owner=1
   e.clan=p.clan
   e.daimyo=p.daimyo

   e.morale=50
   e.fort=max(
    20,
    e.fort-15
   )

   logmsg=
    p.short.." ha conquistato "..e.short

  else

   logmsg=
    p.short.." vince la battaglia"

  end


 else

  p.soldiers=max(
   0,
   p.soldiers-flr(e.soldiers/4)-15
  )

  p.morale=max(
   0,
   p.morale-15
  )

  logmsg="attacco respinto"

 end


 check_end()

end


-- =========================================================
-- turno avversario
-- =========================================================

function enemy_turn()

 if gameover then
  return
 end


 local enemy=nil
 local home=nil


 if provinces[1].owner==2 then
  enemy=provinces[2]
  home=provinces[1]
 else
  enemy=provinces[1]
  home=provinces[2]
 end


 -- se il nemico non possiede piれみ una provincia
 if enemy==nil then
  return
 end


 -- economia
 enemy.rice=min(
  100,
  enemy.rice+3
 )

 enemy.gold=min(
  100,
  enemy.gold+2
 )

 enemy.morale=min(
  100,
  enemy.morale+1
 )


 -- ia semplice
 if enemy.rice<35 then

  enemy.rice=min(
   100,
   enemy.rice+10
  )

  enemy.gold=max(
   0,
   enemy.gold-3
  )

  logmsg="il nemico accumula riso"


 elseif enemy.soldiers<home.soldiers then

  if enemy.rice>=10 then

   enemy.rice-=10

   enemy.soldiers=min(
    100,
    enemy.soldiers+10
   )

   logmsg="il nemico recluta"

  end


 elseif enemy.fort<60 then

  if enemy.gold>=12 then

   enemy.gold-=12

   enemy.fort=min(
    100,
    enemy.fort+8
   )

   logmsg="il nemico rafforza il forte"

  end


 elseif relations==2 and enemy.soldiers>=home.soldiers then

  -- attacco automatico
  enemy_attack(enemy,home)

 else

  enemy.gold=min(
   100,
   enemy.gold+5
  )

  enemy.development=min(
   100,
   enemy.development+2
  )

  logmsg="il nemico sviluppa il dominio"

 end


 check_end()

end


-- =========================================================
-- attacco nemico
-- =========================================================

function enemy_attack(enemy,target)

 local ep=
  enemy.soldiers+
  flr(enemy.morale/2)+
  flr(enemy.development/4)+
  flr(rnd(8))

 local tp=
  target.soldiers+
  flr(target.morale/2)+
  flr(target.fort/3)+
  flr(rnd(8))


 if ep>tp then

  enemy.soldiers=max(
   0,
   enemy.soldiers-flr(target.soldiers/5)-5
  )

  target.soldiers=max(
   0,
   target.soldiers-flr(enemy.soldiers/3)-12
  )

  target.morale=max(
   0,
   target.morale-15
  )

  if target.soldiers<=10 then

   target.owner=2
   target.clan="kato"
   target.daimyo="kato"

   target.morale=40

   logmsg=
    "il nemico conquista "..target.short

  else

   logmsg="il nemico vince una battaglia"

  end

 else

  enemy.soldiers=max(
   0,
   enemy.soldiers-15
  )

  enemy.morale=max(
   0,
   enemy.morale-10
  )

  logmsg="il tuo forte respinge il nemico"

 end

end


-- =========================================================
-- avanzamento turno
-- =========================================================

function advance_turn()

 turn+=1

 season+=1

 if season>4 then

  season=1
  year+=1

 end


 -- produzione base
 for i=1,#provinces do

  local p=provinces[i]

  p.rice=min(
   100,
   p.rice+
   2+
   flr(p.development/25)
  )

  p.gold=min(
   100,
   p.gold+
   1+
   flr(p.development/35)
  )

  p.morale=min(
   100,
   p.morale+1
  )

 end


 -- mantenimento esercito
 local player=provinces[1]

 if player.owner==1 then

  local upkeep=
   flr(player.soldiers/20)

  player.rice=max(
   0,
   player.rice-upkeep
  )

  if player.rice==0 then

   player.morale=max(
    0,
    player.morale-3
   )

  end

 end


 check_end()

end


-- =========================================================
-- controllo vittoria / sconfitta
-- =========================================================

function check_end()

 -- higo conquistata
 if provinces[2].owner==1 then

  gameover=true
  win=true

  return

 end


 -- satsuma perduta
 if provinces[1].owner!=1 then

  gameover=true
  win=false

  return

 end


 -- limite temporale
 if year>=1572 then

  gameover=true
  win=false

  return

 end

end


-- =========================================================
-- nome stagione
-- =========================================================

function season_name()

 if season==1 then
  return "primavera"
 end

 if season==2 then
  return "estate"
 end

 if season==3 then
  return "autunno"
 end

 return "inverno"

end


-- =========================================================
-- sfondo pannelli
-- =========================================================

function draw_panel_bg()

 rectfill(
  0,0,127,127,1
 )

 rectfill(
  3,2,124,124,0
 )

 rect(
  3,2,124,124,7
 )

 -- decorazione minima
 line(3,8,9,2,6)
 line(118,2,124,8,6)

 line(3,118,9,124,6)
 line(118,124,124,118,6)

end


-- =========================================================
-- barre
-- =========================================================

function draw_bar(x,y,value,w)

 value=max(
  0,
  min(100,value)
 )

 rectfill(
  x,y,
  x+w,y+4,
  5
 )

 local f=flr(
  w*value/100
 )

 if f>0 then

  rectfill(
   x+1,
   y+1,
   x+f,
   y+3,
   8
  )

 end

 rect(
  x,y,
  x+w,y+4,
  7
 )

end


-- =========================================================
-- grafico a candele
-- =========================================================

function draw_candle_chart(x,y,v1,v2)

 rectfill(
  x,y,
  x+54,y+33,
  0
 )

 rect(
  x,y,
  x+54,y+33,
  5
 )

 line(
  x+5,y+8,
  x+49,y+8,
  1
 )

 line(
  x+5,y+16,
  x+49,y+16,
  1
 )

 line(
  x+5,y+24,
  x+49,y+24,
  1
 )


 local h1=flr(v1/4)
 local h2=flr(v2/4)


 line(
  x+17,
  y+29-h1,
  x+17,
  y+29,
  7
 )

 rectfill(
  x+13,
  y+22-h1,
  x+21,
  y+29-h1+flr(h1/3),
  8
 )

 rect(
  x+13,
  y+22-h1,
  x+21,
  y+29-h1+flr(h1/3),
  7
 )


 line(
  x+38,
  y+29-h2,
  x+38,
  y+29,
  7
 )

 rectfill(
  x+34,
  y+24-h2,
  x+42,
  y+29-h2+flr(h2/3),
  9
 )

 rect(
  x+34,
  y+24-h2,
  x+42,
  y+29-h2+flr(h2/3),
  7
 )


 print("tu",11,y+27,6)
 print("avv",32,y+27,6)

end


-- =========================================================
-- ritratto daimyo
-- solo primitive
-- =========================================================

function draw_daimyo_portrait(kind,x,y,s)

 local w=40
 local h=58

 rectfill(
  x,y,
  x+w,y+h,
  0
 )

 rect(
  x,y,
  x+w,y+h,
  7
 )

 rectfill(
  x+2,y+2,
  x+w-2,y+h-2,
  1
 )


 local ox=x+20
 local oy=y+27


 -- alone
 circ(
  ox,
  oy-9,
  15,
  5
 )

 circ(
  ox,
  oy-9,
  12,
  1
 )


 -- spalle
 rectfill(
  x+7,y+44,
  x+33,y+55,
  5
 )

 rectfill(
  x+3,y+51,
  x+37,y+56,
  6
 )

 rectfill(
  x+11,y+45,
  x+29,y+55,
  0
 )


 line(
  x+12,y+48,
  x+28,y+48,
  6
 )

 line(
  x+12,y+51,
  x+28,y+51,
  6
 )

 line(
  x+12,y+54,
  x+28,y+54,
  6
 )


 -- collo
 rectfill(
  x+16,y+34,
  x+24,y+47,
  9
 )

 line(
  x+16,y+36,
  x+24,y+36,
  0
 )


 -- orecchie
 rectfill(
  x+7,y+21,
  x+12,y+31,
  9
 )

 rectfill(
  x+28,y+21,
  x+33,y+31,
  9
 )


 -- volto
 circ(
  ox,
  oy,
  14,
  9
 )

 rectfill(
  x+8,y+24,
  x+32,y+33,
  9
 )


 if kind=="shimazu" then

  draw_shimazu_face(x,y)

 else

  draw_kato_face(x,y)

 end


 draw_armor_small(x,y)

end


-- =========================================================
-- volto shimazu
-- =========================================================

function draw_shimazu_face(x,y)

 rectfill(
  x+8,y+12,
  x+32,y+24,
  0
 )

 rectfill(
  x+7,y+19,
  x+12,y+38,
  0
 )

 rectfill(
  x+28,y+19,
  x+33,y+38,
  0
 )


 -- chonmage
 rectfill(
  x+10,y+8,
  x+30,y+13,
  0
 )

 rectfill(
  x+14,y+5,
  x+26,y+9,
  0
 )

 line(
  x+20,y+3,
  x+20,y+8,
  10
 )


 -- sopracciglia
 line(
  x+12,y+23,
  x+18,y+21,
  0
 )

 line(
  x+22,y+21,
  x+28,y+23,
  0
 )


 -- occhi
 rectfill(
  x+12,y+25,
  x+18,y+27,
  7
 )

 rectfill(
  x+22,y+25,
  x+28,y+27,
  7
 )


 pset(
  x+16,y+26,
  0
 )

 pset(
  x+24,y+26,
  0
 )


 -- naso
 line(
  x+20,y+27,
  x+18,y+33,
  8
 )

 line(
  x+18,y+33,
  x+22,y+34,
  8
 )


 -- baffi
 line(
  x+14,y+36,
  x+20,y+34,
  0
 )

 line(
  x+26,y+36,
  x+20,y+34,
  0
 )


 -- barba
 rectfill(
  x+17,y+37,
  x+23,y+41,
  0
 )

 pset(
  x+20,y+42,
  0
 )


 -- bocca
 line(
  x+17,y+36,
  x+23,y+36,
  8
 )


 -- cicatrice
 line(
  x+27,y+29,
  x+29,y+32,
  6
 )

 line(
  x+29,y+29,
  x+27,y+32,
  6
 )


 -- stemma
 circ(
  x+20,y+11,
  2,
  10
 )

 line(
  x+17,y+11,
  x+23,y+11,
  10
 )

end


-- =========================================================
-- volto kato
-- =========================================================

function draw_kato_face(x,y)

 rectfill(
  x+8,y+14,
  x+32,y+25,
  0
 )

 rectfill(
  x+7,y+20,
  x+12,y+35,
  0
 )

 rectfill(
  x+28,y+20,
  x+33,y+35,
  0
 )


 circ(
  x+20,y+7,
  5,
  0
 )

 rectfill(
  x+17,y+4,
  x+23,y+9,
  0
 )


 -- fascia
 rectfill(
  x+8,y+12,
  x+32,y+17,
  8
 )

 line(
  x+10,y+15,
  x+30,y+15,
  0
 )


 -- sopracciglia
 line(
  x+12,y+24,
  x+18,y+25,
  0
 )

 line(
  x+22,y+25,
  x+28,y+24,
  0
 )


 -- occhi
 line(
  x+12,y+27,
  x+18,y+27,
  7
 )

 line(
  x+22,y+27,
  x+28,y+27,
  7
 )


 pset(
  x+16,y+27,
  0
 )

 pset(
  x+24,y+27,
  0
 )


 -- naso
 line(
  x+20,y+28,
  x+22,y+34,
  8
 )

 line(
  x+22,y+34,
  x+19,y+35,
  8
 )


 -- baffi
 line(
  x+13,y+37,
  x+20,y+35,
  0
 )

 line(
  x+27,y+37,
  x+20,y+35,
  0
 )


 -- barba
 line(
  x+16,y+39,
  x+18,y+42,
  0
 )

 line(
  x+18,y+41,
  x+20,y+44,
  0
 )

 line(
  x+24,y+41,
  x+22,y+44,
  0
 )

 line(
  x+26,y+39,
  x+24,y+42,
  0
 )


 -- bocca
 line(
  x+17,y+37,
  x+23,y+37,
  8
 )


 -- stemma
 circ(
  x+20,y+15,
  2,
  10
 )

 pset(
  x+20,y+15,
  7
 )

end


-- =========================================================
-- armatura piccola
-- =========================================================

function draw_armor_small(x,y)

 rectfill(
  x+4,y+45,
  x+14,y+50,
  0
 )

 rectfill(
  x+26,y+45,
  x+36,y+50,
  0
 )


 line(
  x+5,y+48,
  x+13,y+48,
  6
 )

 line(
  x+27,y+48,
  x+35,y+48,
  6
 )


 line(
  x+10,y+47,
  x+15,y+53,
  8
 )

 line(
  x+30,y+47,
  x+25,y+53,
  8
 )


 circ(
  x+20,y+49,
  2,
  10
 )

end


-- =========================================================
-- sigillo
-- =========================================================

function draw_seal(x,y,kind)

 circfill(
  x,y,
  7,
  5
 )

 circ(
  x,y,
  7,
  7
 )


 if kind=="shimazu" then

  line(
   x-4,y-3,
   x+4,y+3,
   0
  )

  line(
   x-4,y+3,
   x+4,y-3,
   0
  )

  circ(
   x,y,
   2,
   0
  )

 else

  rect(
   x-3,y-3,
   x+3,y+3,
   0
  )

  pset(
   x,y,
   7
  )

 end

end


-- =========================================================
-- flood fill mappa
-- =========================================================

function fill_province(x,y,c)

 local old=pget(x,y)

 if old==c then
  return
 end


 local todo={
  {x,y}
 }


 while #todo>0 do

  local p=deli(todo)

  local px=p[1]
  local py=p[2]


  if px>=0 and px<128
  and py>=0 and py<128 then

   if pget(px,py)==old then

    pset(
     px,py,c
    )

    add(
     todo,
     {px+1,py}
    )

    add(
     todo,
     {px-1,py}
    )

    add(
     todo,
     {px,py+1}
    )

    add(
     todo,
     {px,py-1}
    )

   end

  end

 end

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
6666666666666666666666ddddddddddddddddddddddddddddd66666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666000666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666060666666666666666666666666666666666666666666666
6666666666666666666666666666666666666666666666666666666dddddddddd666666666666660660666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666600600666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666606606666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666066066666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666060666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666060666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666660060666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666660660666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666600660066666666666666666666666666666666666666666666666
666666666666666dddddddddddddddddd66666666666666666666666666666666666666666606666066666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666606666066666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666606660066666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666006660666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666066600666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666066606666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666660066606666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666660688600666666666666666666666666666666666666666666666666
6666666666666666666666666666666666666666666666666666ddddddddd6666666666660666666066666666666666666666666666666666666666666666666
6666666666666666666666666666666666666666666ddddddddd666666666666666666660666006006666666dd66666666666666666666666666666666666666
666666666666666666666666666666666666666666666666666666666666666666666666066666606666666666ddd66666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666006666606666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666600000006666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666660066666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666606066666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666006006666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666066606666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666660666606666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666600666606666666666666666666666666666666666666666666666666666666
6666666666666666666666666666666666666666666666666666666666666666600666660666666666666666666666dddddddddd666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666660066666600666666666666666666666666666666ddddddddddd6666666666666
666666666666666666666666666666666666666666666666666666666666660006666666606666666666666dddd6666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666600066666666660666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666600006666666666660666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666006666666660006660666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666600666666666666666660666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666006666666666666666660666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666660666666666666666666660666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666000666666666666666666660666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666066666666660066666666606666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666660666666666666666666666606666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666600666666666666666666666066666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666006666666666666666666666066666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666066666666666666666666666066666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666660066666666666666666cc6660666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666660666666666666666666666660666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666600666666666666666666666660666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666606666600066666666666666006666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666606666666666666666666660066666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666606666666666666666666000666666666666666666666666666666666666666666666666666666666666
66666666666dddddddddddd666666666666666666666606666666666666660000066666666666666666666666666666666666666666666666666666666666666
66666666666666666666666dddddddddddd666666666606666666666666000666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666606666666666660066666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666006666666666606666666666666666666666666666666666666666666666666666666666666666666666
6666666666666666666666666666666666666666666006666666666006666666666666dddddddddddd6666666666666666666666666666666666666666666666
6666666666666666666666666666666666666666600066666666660066666666666666666666666666dddddddddddd6666666666666666666666666666666666
66666666666666666666666666666666666666660066666666666006666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666600666666666666066666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666660066666666666666006666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666600666666666666666606666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666660066666666666666666606666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666000666666666666666666606666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666660066666666600006666666606666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666000666666666666666666666606666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666660066666666666666666666666006666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666660006666666666666666666666660066666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666000000666666666666666666666666600666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666000666666666666666666666666666666006666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666660066666666666600666666666666666666066666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666606666666666666006666666666666660000066666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666006666666666666666666666666666600666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666660066666666666666666666666666666606666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666660666666666666666666666666666666606666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666600666666666666666666666666666666006666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666600006666666666666666666666666666666066666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666006666666666666666666666666666666666066666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666066666666666000666666666666666666660666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666006666666666666666666666666666666660666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666606666666666666666666666666666666000666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666600666666666666666666666666000000066666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666660666666666666666666666660066660666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666660066666666666660006666600666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666006666666666666666666006666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666600666666666666666666066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666660066666666666666660066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666000666666666666660666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666660000006666666660666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
666666666666666666666000666666606666666666666666666666666666666dddddddddddddddddd66666666666666666666666666666666666666666666666
666666666666666666666660006666606666666666666666666666666666666666666666666666666dddddddddddddddddd66666666666666666666666666666
66666666666666666666666666006600666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666600006666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666006666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666600666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
