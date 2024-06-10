--!strict
--Services
--Packages
local Package = script
local Packages = Package.Parent
assert(Packages)
-- Packages
local Maid = require(Packages:WaitForChild("Maid"))
local Signal = require(Packages:WaitForChild("Signal"))

-- Modules

-- Constants
local DISTANT_CF = CFrame.new(0, 0, 1_000_000)

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
export type InstancePool = {
	__index: InstancePool,
	Maid: Maid,
	Template: Instance,
	Amount: number,
	Available: { [number]: Instance },
	Get: (self: InstancePool) -> Instance,
	Reset: (self: InstancePool, inst: Instance) -> nil,
	new: (inst: Instance, amount: number) -> InstancePool,
	Destroy: (self: InstancePool) -> nil,
}

-- Class
local ObjectPool: InstancePool = {} :: any
ObjectPool.__index = ObjectPool

function ObjectPool:Get()
	local i = #self.Available
	local inst = self.Available[i]
	if inst then
		table.remove(self.Available, i)
		return inst
	else
		local tempCopy = self.Template:Clone()
		self.Maid:GiveTask(tempCopy)
		return tempCopy
	end
end

function ObjectPool:Reset(inst: Instance)
	if inst:IsA("Model") then
		inst:PivotTo(DISTANT_CF)
	elseif inst:IsA("BasePart") then
		inst.CFrame = DISTANT_CF
	end

	table.insert(self.Available, inst)
	return nil
end

function ObjectPool:Destroy()
	self.Maid:Destroy()
	local t: any = self
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(t, nil)
	return nil
end

function ObjectPool.new(template: Instance, amount: number): InstancePool
	local self: InstancePool = setmetatable({
		Maid = Maid.new(),
		Template = template,
		Amount = amount,
		Available = {},
	}, ObjectPool) :: any
	self.Maid:GiveTask(self.Template)
	for i = 1, self.Amount do
		local tempCopy = self.Template:Clone()
		self.Maid:GiveTask(tempCopy)
		table.insert(self.Available, tempCopy)
	end

	return self
end

return ObjectPool

