class DXRHordeMode extends DXRActorsBase transient;

var int wave;
var int time_to_next_wave;
var config int time_between_waves;
var bool in_wave;
var int time_in_wave;
var config int time_before_damage;
var config int damage_timer;
var config int time_before_teleport_enemies;
var config float popin_dist;
var config int skill_points_award;
var config int early_end_wave_timer;
var config int early_end_wave_enemies;
var config int items_per_wave;
var config int enemies_per_wave;
var config int enemies_first_wave;

struct EnemyChances {
    var string type;
    var float difficulty;
    var int minWave;
    var int maxWave;
    var int chance;
};
var config EnemyChances enemies[32];
var class<ScriptedPawn> enemyclasses[32];

struct ItemChances {
    var string type;
    var int chance;
};
var config ItemChances items[16];

function CheckConfig()
{
    local int i;
    if( config_version == 0 ) {
        time_between_waves = 65;
        time_before_damage = 180;
        damage_timer = 5;
        time_before_teleport_enemies = 30;
        early_end_wave_timer = 240;
        early_end_wave_enemies = 5;
        popin_dist = 1500.0;
        skill_points_award = 2500;
        items_per_wave = 20;
        enemies_per_wave = 2;
        enemies_first_wave = 2;
        for(i=0; i < ArrayCount(enemies); i++) {
            enemies[i].type = "";
            enemies[i].chance = 0;
            enemies[i].minWave = 1;
            enemies[i].maxWave = 99999;
            enemies[i].difficulty = 1;
        }
        i=0;
        enemies[i].type = "Terrorist";
        enemies[i].chance = 10;
        i++;
        enemies[i].type = "UNATCOTroop";
        enemies[i].chance = 10;
        i++;
        enemies[i].type = "ThugMale";
        enemies[i].chance = 10;
        i++;
        enemies[i].type = "ThugMale2";
        enemies[i].chance = 10;
        i++;
        enemies[i].type = "ThugMale3";
        enemies[i].chance = 10;
        i++;
        enemies[i].type = "MJ12Commando";
        enemies[i].chance = 5;
        enemies[i].minWave = 3;
        enemies[i].difficulty = 2;
        i++;
        enemies[i].type = "MJ12Troop";
        enemies[i].chance = 5;
        enemies[i].minWave = 2;
        enemies[i].difficulty = 2;
        i++;
        enemies[i].type = "MIB";
        enemies[i].chance = 2;
        enemies[i].minWave = 4;
        enemies[i].difficulty = 2;
        /*i++;
        enemies[i].type = "WIB";
        enemies[i].chance = 2;
        enemies[i].minWave = 4;
        enemies[i].difficulty = 2;*/
        i++;
        enemies[i].type = "SpiderBot2";
        enemies[i].chance = 2;
        enemies[i].minWave = 5;
        enemies[i].difficulty = 2;
        i++;
        enemies[i].type = "MilitaryBot";
        enemies[i].chance = 1;
        enemies[i].minWave = 10;
        enemies[i].difficulty = 5;
        i++;
        enemies[i].type = "SecurityBot2";
        enemies[i].chance = 1;
        enemies[i].minWave = 7;
        enemies[i].difficulty = 4;
        i++;
        enemies[i].type = "SecurityBot3";
        enemies[i].chance = 1;
        enemies[i].minWave = 7;
        enemies[i].difficulty = 4;
        i++;
        enemies[i].type = "SecurityBot4";
        enemies[i].chance = 1;
        enemies[i].minWave = 7;
        enemies[i].difficulty = 4;

        i=0;
        items[i].type = "BioelectricCell";
        items[i].chance = 14;
        i++;
        items[i].type = "CrateExplosiveSmall";
        items[i].chance = 14;
        i++;
        items[i].type = "Barrel1";
        items[i].chance = 14;
        i++;
        items[i].type = "WeaponGasGrenade";
        items[i].chance = 7;
        i++;
        items[i].type = "WeaponLAM";
        items[i].chance = 6;
        i++;
        items[i].type = "WeaponEMPGrenade";
        items[i].chance = 6;
        i++;
        items[i].type = "WeaponNanoVirusGrenade";
        items[i].chance = 6;
        i++;
        items[i].type = "FireExtinguisher";
        items[i].chance = 5;
        i++;
        items[i].type = "Ammo10mm";
        items[i].chance = 6;
        i++;
        items[i].type = "Ammo762mm";
        items[i].chance = 6;
        i++;
        items[i].type = "AmmoShell";
        items[i].chance = 6;
        // and 10% more...
        i++;
        items[i].type = "AugmentationCannister";
        items[i].chance = 3;
        i++;
        items[i].type = "MedicalBot";
        items[i].chance = 3;
        i++;
        items[i].type = "MedKit";
        items[i].chance = 2;
        i++;
        items[i].type = "AugmentationUpgradeCannister";
        items[i].chance = 2;
    }
    Super.CheckConfig();

    for(i=0; i < ArrayCount(enemies); i++) {
        if(enemies[i].type == "") continue;
        enemyclasses[i] = class<ScriptedPawn>(GetClassFromString(enemies[i].type, class'ScriptedPawn'));
    }
}

function AnyEntry()
{
    local Actor a;
    local Teleporter t;
    local DeusExMover d;
    local DXREnemies dxre;
    local Inventory item;

    if( dxr.flags.gamemode != 2 ) return;

    if( dxr.dxInfo.missionNumber>0 && dxr.localURL != "11_PARIS_CATHEDRAL" ) {
        Level.Game.SendPlayer(dxr.player, "11_PARIS_CATHEDRAL");
        return;
    }
    else if( dxr.localURL != "11_PARIS_CATHEDRAL" ) {
        return;
    }

    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
    if( dxre == None ) {
        err("Could not find DXREnemies! This is required for Horde Mode.");
    }
    dxre.GiveRandomWeapon(dxr.Player);
    dxre.GiveRandomWeapon(dxr.Player);
    dxre.GiveRandomMeleeWeapon(dxr.Player);
    item = Spawn(class'Medkit', dxr.player);
    item.GiveTo(dxr.player);
    item.SetBase(dxr.player);
    item = Spawn(class'FireExtinguisher', dxr.player);
    item.GiveTo(dxr.player);
    item.SetBase(dxr.player);
    dxr.Player.dataLinkPlay = Spawn(class'DataLinkPlay');//this prevents saving the game :)

    time_to_next_wave = time_between_waves;

    foreach AllActors(class'Teleporter', t) {
        t.bEnabled = false;// seems like teleporters are baked into the level's collision, so destroying them at runtime has no effect
    }
    foreach AllActors(class'Actor', a) {
        if( a.IsA('MapExit')
            || a.IsA('ScriptedPawn')
            || a.IsA('DataLinkTrigger')
            || a.IsA('MapExit')
            || a.IsA('Teleporter')
            || a.IsA('SecurityCamera')
            || a.IsA('AutoTurret')
        ){
            a.Destroy();
        }
    }
    foreach AllActors(class'DeusExMover', d, 'cathedralgatekey') {
        d.bLocked = false;
    }
    foreach AllActors(class'DeusExMover', d, 'BreakableGlass') {
        if (
            d.Name == 'BreakableGlass0'
            || d.Name == 'BreakableGlass1'
            || d.Name == 'BreakableGlass2'
            || d.Name == 'BreakableGlass3'
        ) d.bBreakable = false;
    }
    SetTimer(1.0, true);

    GenerateItems();
}

function Timer()
{
    if( in_wave )
        InWaveTick();
    else
        OutOfWaveTick();
}

function InWaveTick()
{
    local ScriptedPawn p;
    local int numScriptedPawns;
    local float dist, ratio;

    foreach AllActors(class'ScriptedPawn', p) {
        if( p.IsA('Animal') ) continue;
        if( (time_in_wave+numScriptedPawns) % 5 == 0 ) p.SetOrders('Attacking');
        dist = VSize(p.Location-dxr.player.Location);
        if( dist > popin_dist ) {
            ratio = dist/popin_dist;
            p.GroundSpeed = p.class.default.GroundSpeed * ratio*ratio;
        } else {
            p.GroundSpeed = p.class.default.GroundSpeed;
        }
        numScriptedPawns++;
    }

    if( numScriptedPawns == 0 || ( time_in_wave > early_end_wave_timer && numScriptedPawns <= early_end_wave_enemies ) ) {
        EndWave();
        return;
    }

    time_in_wave++;
    NotifyPlayerPawns(numScriptedPawns);

    if( time_in_wave > time_before_damage && time_in_wave%damage_timer == 0 ) {
        dxr.player.TakeDamage(1, dxr.player, dxr.player.Location, vect(0,0,0), 'Shocked');
        PlaySound(sound'ProdFire');
        PlaySound(sound'MalePainSmall');
    }
    else if( time_in_wave <= time_before_damage && time_in_wave+5 > time_before_damage ) {
        dxr.player.ClientMessage( (time_before_damage-time_in_wave) $ " seconds until shocking.");
    }
    if( time_in_wave > time_before_teleport_enemies ) {
        ComeCloser();
    }
}

function OutOfWaveTick()
{
    time_to_next_wave--;
    NotifyPlayerTime();

    if( time_to_next_wave <= 0 ) {
        StartWave();        
    }
}

function StartWave()
{
    local MedicalBot mb;
    local DeusExCarcass c;
    local int num_carcasses;
    foreach AllActors(class'MedicalBot', mb) {
        mb.TakeDamage(10000, mb, mb.Location, vect(0,0,0), 'Exploded');
    }
    foreach AllActors(class'DeusExCarcass', c) {
        if( c.Inventory == None ) c.Destroy();//TakeDamage(10000, None, c.Location, vect(0,0,0), 'Exploded');
        else num_carcasses++;
    }
    if( num_carcasses > 50 ) {
        foreach AllActors(class'DeusExCarcass', c) {
            //c.TakeDamage(10000, None, c.Location, vect(0,0,0), 'Exploded');
            c.Destroy();
        }
    }
    in_wave = true;
    time_in_wave = 0;
    wave++;
    GenerateEnemies();
}

function EndWave()
{
    in_wave=false;
    time_to_next_wave = time_between_waves;
    dxr.player.SkillPointsAdd(skill_points_award);
    GenerateItems();
}

function ComeCloser()
{
    local ScriptedPawn p;
    local int i, time_overdue;
    local vector loc;
    local float dist, maxdist;

    time_overdue = time_in_wave-time_before_teleport_enemies;
    maxdist = popin_dist - float(time_overdue*5);
    foreach AllActors(class'ScriptedPawn', p) {
        if( p.IsA('Animal') ) continue;

        dist = VSize(dxr.player.Location-p.Location);
        if( (time_in_wave+i) % 3 == 0 && p.CanSee(dxr.player) == false && dist > maxdist ) {
            loc = GetCloserPosition(dxr.player.Location, p.Location);
            loc.X += float(rng(50000))/50000.0 * 50.0;
            loc.Y += float(rng(50000))/50000.0 * 50.0;
            p.SetLocation( loc );
        }
        else if( (time_in_wave+i) % 7 == 0 && p.CanSee(dxr.player) == false && dist > maxdist*2 ) {
            loc = GetRandomPosition(dxr.player.Location, maxdist, dist);
            loc.X += float(rng(50000))/50000.0 * 50.0;
            loc.Y += float(rng(50000))/50000.0 * 50.0;
            p.SetLocation(loc);
        }
        i++;
    }
}

function NotifyPlayerPawns(int numScriptedPawns)
{
    if( numScriptedPawns > 10 ) return;
    if( time_in_wave % 3 != 0 ) return;

    dxr.player.ClientMessage(numScriptedPawns $ " enemies remaining.");
}

function NotifyPlayerTime()
{
    if(time_to_next_wave<0) return;

    if(
        (time_to_next_wave >= 60 && time_to_next_wave % 60 == 0)
        || (time_to_next_wave < 60 && time_to_next_wave % 10 == 0)
        || (time_to_next_wave <= 10)
    ) {
        dxr.player.ClientMessage("Wave "$ (wave+1) $" in " $ time_to_next_wave $ " seconds.");
    }
}

function GenerateEnemies()
{
    local DXREnemies dxre;
    local int i, numEnemies;
    local float difficulty, maxdifficulty;
    
    dxr.SetSeed( dxr.seed + wave + dxr.Crc( "Horde GenerateEnemies") );
    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
    if( dxre == None ) {
        return;
    }

    numEnemies = (wave-1)*enemies_per_wave+enemies_first_wave;
    maxdifficulty = float(numEnemies);
    for(i=0; i<numEnemies*2 || difficulty < 0.1 ; i++) {
        difficulty += GenerateEnemy(dxre);
        if( i>=numEnemies && difficulty > maxdifficulty ) break;
    }
}

function float GenerateEnemy(DXREnemies dxre)
{
    local class<ScriptedPawn> c;
    local ScriptedPawn p;
    local int i,r;
    local float difficulty, dist;
    local vector loc;

    r = initchance();
    for(i=0; i < ArrayCount(enemies); i++ ) {
        if( enemies[i].minWave > wave ) continue;
        if( enemies[i].maxWave < wave ) continue;
        if( chance( enemies[i].chance, r ) ) {
            c = enemyclasses[i];
            difficulty = enemies[i].difficulty;
        }
    }
    chance_remaining(r);

    if( c == None ) {
        return 0;
    }
    p = None;
    for(i=0; i < 10 && p == None; i++ ) {
        loc = GetRandomPosition(dxr.player.Location, popin_dist, popin_dist*10);
        loc.X += float(rng(50000))/50000.0 * 50.0;
        loc.Y += float(rng(50000))/50000.0 * 50.0;
        p = Spawn(c,,, loc );
    }
    if(p==None) {
        l("failed to spawn "$c$" at "$loc);
        return 0;
    }

    p.Intelligence = BRAINS_Human;
    p.MinHealth = 0;//never flee from battle
    SetAlliance(p);
    p.SetOrders('Attacking');
    dxre.RandomizeSP(p, 100);
    GiveRandomItems(p);
    p.InitializeInventory();

    return difficulty;
}

function GiveRandomItems(ScriptedPawn p)
{
    local Inventory item;
    item = Spawn(class'WineBottle', p);// this is how Paris works in real life, right?
    item.GiveTo(p);
    item.SetBase(p);
}

function SetAlliance(ScriptedPawn p)
{
    local int i;
    p.Alliance = 'horde';
    for(i=0; i<ArrayCount(p.InitialAlliances); i++ )
    {
        p.InitialAlliances[i].AllianceName = '';
        p.InitialAlliances[i].AllianceLevel = 0;
    }
    /*for(i=0; i<ArrayCount(p.AlliancesEx); i++ ) {
        p.AlliancesEx[i].AllianceName = '';
    }*/
    p.InitialAlliances[0].AllianceName = 'horde';
    p.InitialAlliances[0].AllianceLevel = 1;
    p.InitialAlliances[0].bPermanent = true;

    p.InitialAlliances[1].AllianceName = dxr.player.Alliance;
    p.InitialAlliances[1].AllianceLevel = -1;
    p.InitialAlliances[1].bPermanent = true;

    p.SetAlliance(p.Alliance);
    p.InitializeAlliances();
    //p.SetEnemy(dxr.player, 0, true);
}

function GenerateItems()
{
    local int i;
    dxr.SetSeed( dxr.seed + wave + dxr.Crc( "Horde GenerateItems") );
    for(i=0;i<items_per_wave;i++) {
        GenerateItem();
    }
}

function GenerateItem()
{
    local int i,r, num;
    local Actor a;
    local class<Actor> c;
    local vector loc;
    local AugmentationCannister aug;
    local Barrel1 barrel;
    r = initchance();
    for(i=0; i < ArrayCount(items); i++) {
        if( chance(items[i].chance, r) ) c = GetClassFromString(items[i].type, class'Actor');
    }
    foreach AllActors(class'Actor', a) {
        if( a.class == c ) {
            num++;
            if( num > items_per_wave ) {
                l("already have too many of "$c.name);
                loc = GetRandomPosition();
                loc.X += float(rng(50000))/50000.0 * 50.0;
                loc.Y += float(rng(50000))/50000.0 * 50.0;
                a.SetLocation(loc);
            }
            if( num > items_per_wave*2 )
                return;
        }
    }
    for(i=0; i<10 && a == None; i++) {
        loc = GetRandomPosition();
        loc.X += float(rng(50000))/50000.0 * 50.0;
        loc.Y += float(rng(50000))/50000.0 * 50.0;
        a = Spawn(c,,, loc);
    }
    if(c==None) {
        l("failed to spawn "$c$" at "$loc);
        return ;
    }

    aug = AugmentationCannister(a);
    barrel = Barrel1(a);

    if( aug != None ) {
        class'DXRAugmentations'.static.RandomizeAugCannister(dxr, aug);
    }
    else if( barrel != None ) {
        barrel.SkinColor = SC_Poison;
        barrel.BeginPlay();
    }
}
