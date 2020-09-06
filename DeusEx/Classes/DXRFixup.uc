class DXRFixup expands DXRBase;

struct DecorationsOverwrite {
    var class<DeusExDecoration> type;
    var bool bInvincible;
    var int HitPoints;
    var int minDamageThreshold;
    var bool bFlammable;
    var float Flammability; // how long does the object burn?
    var bool bExplosive;
    var int explosionDamage;
    var float explosionRadius;
    var bool bPushable;
};

var config DecorationsOverwrite DecorationsOverwrites[16];

function CheckConfig()
{
    local int i;
    if( config_version == 0 ) {
        for(i=0; i < ArrayCount(DecorationsOverwrites); i++) {
            DecorationsOverwrites[i].type = None;
        }
        i=0;
        DecorationsOverwrites[i].type = class'CrateUnbreakableLarge';
        DecorationsOverwrites[i].bInvincible = false;
        DecorationsOverwrites[i].HitPoints = 2000;
        DecorationsOverwrites[i].minDamageThreshold = 0;
        DecorationsOverwrites[i].bFlammable = DecorationsOverwrites[i].type.default.bFlammable;
        DecorationsOverwrites[i].Flammability = DecorationsOverwrites[i].type.default.Flammability;
        DecorationsOverwrites[i].bExplosive = DecorationsOverwrites[i].type.default.bExplosive;
        DecorationsOverwrites[i].explosionDamage = DecorationsOverwrites[i].type.default.explosionDamage;
        DecorationsOverwrites[i].explosionRadius = DecorationsOverwrites[i].type.default.explosionRadius;
        DecorationsOverwrites[i].bPushable = DecorationsOverwrites[i].type.default.bPushable;
        i++;

        DecorationsOverwrites[i].type = class'BarrelFire';
        DecorationsOverwrites[i].bInvincible = false;
        DecorationsOverwrites[i].HitPoints = 50;
        DecorationsOverwrites[i].minDamageThreshold = 0;
        DecorationsOverwrites[i].bFlammable = DecorationsOverwrites[i].type.default.bFlammable;
        DecorationsOverwrites[i].Flammability = DecorationsOverwrites[i].type.default.Flammability;
        DecorationsOverwrites[i].bExplosive = DecorationsOverwrites[i].type.default.bExplosive;
        DecorationsOverwrites[i].explosionDamage = DecorationsOverwrites[i].type.default.explosionDamage;
        DecorationsOverwrites[i].explosionRadius = DecorationsOverwrites[i].type.default.explosionRadius;
        DecorationsOverwrites[i].bPushable = DecorationsOverwrites[i].type.default.bPushable;
    }
    Super.CheckConfig();
}

function FirstEntry()
{
    Super.FirstEntry();
    l( "mission " $ dxr.dxInfo.missionNumber $ " FirstEntry()");

    IncreaseBrightness(dxr.flags.brightness);
    OverwriteDecorations();
    
    if (dxr.dxInfo.missionNumber == 2)
        NYC1_FirstEntry();
    else if( dxr.dxInfo.missionNumber == 6 )
        HongKong_FirstEntry();
    else if( dxr.dxInfo.missionNumber == 12 )
        Vandenberg_FirstEntry();
}

function AnyEntry()
{
    Super.AnyEntry();
    l( "mission " $ dxr.dxInfo.missionNumber $ " AnyEntry()");

    BuffScopes();

    if( dxr.dxInfo.missionNumber == 6 )
        HongKong_AnyEntry();
}

function IncreaseBrightness(int brightness)
{
    local ZoneInfo z;
    if(brightness <= 0) return;

    Level.AmbientBrightness = Clamp( int(Level.AmbientBrightness) + brightness, 0, 255 );
    //Level.Brightness += float(brightness)/100.0;
    foreach AllActors(class'ZoneInfo', z) {
        if( z == Level ) continue;
        z.AmbientBrightness = Clamp( int(z.AmbientBrightness) + brightness, 0, 255 );
    }
}

function BuffScopes()
{
    local DXRScopeView scope;
    local DeusExRootWindow win;

    win = DeusExRootWindow(dxr.Player.rootWindow);
    if ( win.scopeView.IsA('DXRScopeView') == false ) {
        scope = DXRScopeView(win.NewChild(Class'DXRScopeView', False));
        scope.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0, 0);
        scope.Lower();
        win.scopeView = scope;
    }
}

function OverwriteDecorations()
{
    local DeusExDecoration d;
    local int i;
    for(i=0; i < ArrayCount(DecorationsOverwrites); i++) {
        if(DecorationsOverwrites[i].type == None) continue;
        foreach AllActors(class'DeusExDecoration', d) {
            if( d.IsA(DecorationsOverwrites[i].type.name) == false ) continue;
            d.bInvincible = DecorationsOverwrites[i].bInvincible;
            d.HitPoints = DecorationsOverwrites[i].HitPoints;
            d.minDamageThreshold = DecorationsOverwrites[i].minDamageThreshold;
            d.bFlammable = DecorationsOverwrites[i].bFlammable;
            d.Flammability = DecorationsOverwrites[i].Flammability;
            d.bExplosive = DecorationsOverwrites[i].bExplosive;
            d.explosionDamage = DecorationsOverwrites[i].explosionDamage;
            d.explosionRadius = DecorationsOverwrites[i].explosionRadius;
            d.bPushable = DecorationsOverwrites[i].bPushable;
        }
    }
}

function NYC1_FirstEntry()
{
    local NYPoliceBoat b;
    
    switch (dxr.localURL)
    {
        case "02_NYC_BATTERYPARK":
            foreach AllActors(class'NYPoliceBoat',b) {
                b.BindName = "NYPoliceBoat";
                b.ConBindEvents();
            }
            break;
    }
}

function Vandenberg_FirstEntry()
{
    local ElevatorMover e;
    local Button1 b;
    local Dispatcher d;
    local LogicTrigger lt;

    switch(dxr.localURL)
    {
        case "12_VANDENBERG_CMD":
            foreach AllActors(class'Dispatcher', d)
            {
                switch(d.Tag)
                {
                    case 'overload2':
                        d.tag = 'overload2disp';
                        lt = Spawn(class'LogicTrigger',,,d.Location);
                        lt.Tag = 'overload2';
                        lt.Event = 'overload2disp';
                        lt.inGroup1 = 'sec_switch2';
                        lt.inGroup2 = 'sec_switch2';
                        lt.OneShot = True;
                        break;
                    case 'overload1':
                        d.tag = 'overload1disp';
                        lt = Spawn(class'LogicTrigger',,,d.Location);
                        lt.Tag = 'overload1';
                        lt.Event = 'overload1disp';
                        lt.inGroup1 = 'sec_switch1';
                        lt.inGroup2 = 'sec_switch1';
                        lt.OneShot = True;
                        break;
                }
            }
            break;
        case "12_VANDENBERG_TUNNELS":
            foreach AllActors(class'ElevatorMover', e, 'Security_door3') {
                e.BumpType = BT_PlayerBump;
                e.BumpEvent = 'SC_Door3_opened';
            }
            foreach AllActors(class'Button1', b) {
                if( b.Event == 'Top' || b.Event == 'middle' || b.Event == 'Bottom' ) {
                    AddDelay(b, 5);
                }
            }
            break;
    }
}

function HongKong_FirstEntry()
{
    local Actor a;
    local ScriptedPawn p;

    switch(dxr.localURL)
    {
        case "06_HONGKONG_TONGBASE":
            foreach AllActors(class'Actor', a)
            {
                switch(string(a.Tag))
                {
                    case "AlexGone":
                    case "TracerGone":
                    case "JaimeGone":
                        a.Destroy();
                        break;
                    case "Breakintocompound":
                    case "LumpathPissed":
                        Trigger(a).bTriggerOnceOnly = False;
                        break;
                    default:
                        break;
                }
            }    
            break;
        case "06_HONGKONG_WANCHAI_MARKET":
            foreach AllActors(class'Actor', a)
            {
                switch(string(a.Tag))
                {
                    case "DummyKeypad01":
                        a.Destroy();
                        break;
                    case "BasementKeypad":
                    case "GateKeypad":
                        a.bHidden=False;
                        break;    
                    case "Breakintocompound":
                    case "LumpathPissed":
                        Trigger(a).bTriggerOnceOnly = False;
                        break;
                    default:
                        break;
                }
            }
            
            break;
        default:
            break;
    }
}

function HongKong_AnyEntry()
{
    local Actor a;
    local ScriptedPawn p;
    local bool boolFlag;
    local bool recruitedFlag;

    switch(dxr.localURL)
    {
        case "06_HONGKONG_TONGBASE":
            boolFlag = dxr.Player.flagBase.GetBool('QuickLetPlayerIn');
            foreach AllActors(class'Actor', a)
            {
                switch(string(a.Tag))
                {
                    case "TriadLumPath":
                        ScriptedPawn(a).ChangeAlly(dxr.Player.Alliance,1,False);
                        break;
                        
                    case "TracerTong":                      
                        if ( boolFlag == True )
                        {
                            ScriptedPawn(a).EnterWorld();                    
                        } else {
                            ScriptedPawn(a).LeaveWorld();
                        }
                        break;
                    case "AlexJacobson":
                        recruitedFlag = dxr.Player.flagBase.GetBool('JacobsonRecruited');
                        if ( boolFlag == True && recruitedFlag == True)
                        {
                            ScriptedPawn(a).EnterWorld();                    
                        } else {
                            ScriptedPawn(a).LeaveWorld();
                        }
                        break;
                    case "JaimeReyes":
                        recruitedFlag = dxr.Player.flagBase.GetBool('JaimeRecruited');
                        if ( boolFlag == True && recruitedFlag == True)
                        {
                            ScriptedPawn(a).EnterWorld();                    
                        } else {
                            ScriptedPawn(a).LeaveWorld();
                        }
                        break;
                    case "Operation1":
                        DataLinkTrigger(a).checkFlag = 'QuickLetPlayerIn';
                        break;
                    case "TurnOnTheKillSwitch":
                        if (boolFlag == True)
                        {
                            Trigger(a).TriggerType = TT_PlayerProximity;                        
                        } else {
                            Trigger(a).TriggerType = TT_ClassProximity;
                            Trigger(a).ClassProximityType = class'Teleporter';//Impossible, thus disabling it
                        }
                        break;
                    default:
                        break;
                }
            }    
            break;
        case "06_HONGKONG_WANCHAI_MARKET":
            foreach AllActors(class'Actor', a)
            {
                switch(string(a.Tag))
                {
                    case "TriadLumPath":
                    case "TriadLumPath1":
                    case "TriadLumPath2":
                    case "TriadLumPath3":
                    case "TriadLumPath4":
                    case "TriadLumPath5":
                    case "GordonQuick":
                    
                        ScriptedPawn(a).ChangeAlly(dxr.Player.Alliance,1,False);
                        break;
                }
            }

            break;
        default:
            break;
    }
}

function AddDelay(Actor trigger, float time)
{
    local Dispatcher d;
    local name tagname;
    tagname = dxr.Player.rootWindow.StringToName( "dxr_delay_" $ trigger.Event );
    d = Spawn(class'Dispatcher', trigger, tagname);
    d.OutEvents[0] = trigger.Event;
    d.OutDelays[0] = time;
    trigger.Event = d.Tag;
}

defaultproperties
{
}
