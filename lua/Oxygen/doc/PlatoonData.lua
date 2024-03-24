---@meta

---@alias StructureType
--- |
--- |
--- |
--- | 'T3Artillery'
--- | 'T2Artillery'
--- | 'T2ShieldDefense'
--- | 'T3AADefense'
--- | 'T2GroundDefense'

---@class ConstructionTable
---@field BaseTemplate UnitGroup
---@field BuildClose boolean
---@field BuildStructures StructureType[]


---@class Transporting_PlatoonDataTable
---@field TransportReturn Marker? @Location for transports to return to (they will attack with land units if this isn't set)
---@field UseTransports boolean?
---@field TransportRoute  Marker[]?
---@field TransportChain MarkerChain?
---@field LandingLocation Marker


---@class StartBaseEngineerThread_PlatoonDataTable: Transporting_PlatoonDataTable



---@class LandAssaultWithTransports_PlatoonDataTable:Transporting_PlatoonDataTable
---@field TransportChain MarkerChain?
---@field AssaultChains MarkerChain[]?
---@field AttackChain MarkerChain?
---@field LandingChain MarkerChain?
---@field LandingList Marker[]? @List of possible locations for transports to unload units
---@field RandomPatrol boolean?
---@field PatrolChain MarkerChain?

---@class PlatoonDataTable : LandAssaultWithTransports_PlatoonDataTable, StartBaseEngineerThread_PlatoonDataTable
---@field PatrolChains MarkerChain[]?
---@field PatrolChain MarkerChain?
---@field LocationChain MarkerChain?
---@field CategoryList EntityCategory[]?
---@field Location Marker?
---@field High boolean?
---@field Construction ConstructionTable
---@field MaintainBaseTemplate UnitGroup
