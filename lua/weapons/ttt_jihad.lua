-- First some standard GMod stuff
if SERVER then
   AddCSLuaFile()
end

if CLIENT then
   SWEP.PrintName = "Jihad Bomb"
   SWEP.Slot = 6
   SWEP.Icon = "VGUI/ttt/icon_ttt_jihad"
   
   -- Text shown in the equip menu
   SWEP.EquipMenuData = {
      type = "Weapon",
      desc = "A weapon that when activated blows you up with the rest of your surroundings."
   };
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

-- Standard GMod values
SWEP.HoldType = "slam"

SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 5
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.ClipMax = -1

-- Model properties
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 70
SWEP.ViewModel = Model( "models/weapons/cstrike/c_c4.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_c4.mdl" )

-- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "none"

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_TRAITOR }

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, None.
SWEP.InLoadoutFor = { nil }

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

-- Tell the server that it should download our icon to clients.
if SERVER then
   -- It's important to give your icon a unique name. GMod does NOT check for
   -- file differences, it only looks at the name. This means that if you have
   -- an icon_ak47, and another server also has one, then players might see the
   -- other server's dumb icon. Avoid this by using a unique name.
   resource.AddFile("materials/VGUI/ttt/icon_ttt_jihad.vmt")
end

-- Precache custom sounds
function SWEP:Precache()
   util.PrecacheSound( "weapons/ttt_jihad/big_explosion.wav" )
   util.PrecacheSound( "weapons/ttt_jihad/jihad.wav" )
end

-- Reload does nothing
function SWEP:Reload()
end

-- Particle effects / Begin attack
function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire( CurTime() + 2 )

   local effectdata = EffectData()
   effectdata:SetOrigin( self.Owner:GetPos() )
   effectdata:SetNormal( self.Owner:GetPos() )
   effectdata:SetMagnitude( 8 )
   effectdata:SetScale( 1 )
   effectdata:SetRadius( 78 )
   util.Effect( "Sparks", effectdata )
   self.BaseClass.ShootEffects( self )

   -- The rest is done on the server
   if ( SERVER ) then
      timer.Simple( 2, function() self:Explode() end )
      self.Owner:EmitSound( "weapons/ttt_jihad/jihad.wav" )
   end
end

-- Explosion properties
function SWEP:Explode()
   local ent = ents.Create( "env_explosion" )
   ent:SetPos( self.Owner:GetPos() )
   ent:SetOwner( self.Owner )
   ent:SetKeyValue( "iMagnitude", "200" )
   ent:Spawn()
   ent:Fire( "Explode", 0, 0 )
   ent:EmitSound( "weapons/ttt_jihad/big_explosion.wav", 500, 255 )
   self:Remove()
end