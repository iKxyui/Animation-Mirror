local AnimMirror = {}

-- Table containing the paired names of the body parts, NOT the names of the joints
local bodyPartPairs = {
	{"Head"};
	{"Torso"};
	{"Left Arm", "Right Arm"};
	{"Left Leg", "Right Leg"};
	{"HumanoidRootPart"}
}

local function MirrorPoseCFrame(cf)
	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components()
	x = -x
	-- R00, R10, R20 (x)
	R10 = -R10
	R20 = -R20
	-- R01, R11, R21 (y) 
	R01 = -R01
	-- R02, R12, R22 (z) 
	R02 = -R02
	return CFrame.new(x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
end

local function GetKeyframeSequenceLength(keyframeSequence)
	local keyframes = keyframeSequence:GetChildren()
	local max = keyframes[1].Time    
	for i, v in pairs(keyframes) do
		if v.Time > max then
			max = v.Time
		end
	end
	return max        
end

local function MirrorKeyframe(keyframe)
	for i, v in pairs(bodyPartPairs) do
		if #v == 1 then
			local pose = keyframe:FindFirstChild(v[1], true)
			if pose then
				pose.CFrame = MirrorPoseCFrame(pose.CFrame)
			end
		elseif #v == 2 then
			local leftName = v[1]
			local rightName = v[2]
			local leftPose = keyframe:FindFirstChild(leftName, true)
			local rightPose = keyframe:FindFirstChild(rightName, true)
			if leftPose and rightPose then 
				leftPose.Name = rightName
				rightPose.Name = leftName
				leftPose.CFrame = MirrorPoseCFrame(leftPose.CFrame)
				rightPose.CFrame = MirrorPoseCFrame(rightPose.CFrame)
			elseif leftPose then
				leftPose.Name = rightName
				leftPose.CFrame = MirrorPoseCFrame(leftPose.CFrame)
			elseif rightPose then
				rightPose.Name = leftName
				rightPose.CFrame = MirrorPoseCFrame(rightPose.CFrame)
			end
		end
	end
end

local function SymmetricKeyframeSequence(KeyframeSequence,MIRROR_GAP)
	local length = GetKeyframeSequenceLength(KeyframeSequence)
	for i, v in pairs(KeyframeSequence:GetChildren()) do
		local KeyframeClone = v:Clone()
		KeyframeClone.Name = v.Name .. "_Mirrored"
		KeyframeClone.Time = length + KeyframeClone.Time + MIRROR_GAP        
		MirrorKeyframe(KeyframeClone)
		KeyframeClone.Parent = KeyframeSequence
	end
end

function AnimMirror:MirrorAnimation(Properties)
	local MIRROR_GAP = 0 -- Variable is to determine how far apart the unmirrored and mirrored parts are (0.1667)
	local keyframeSequenceOrig = Properties.Directory[Properties.Animation]
	local KeyframeSequenceClone = keyframeSequenceOrig:Clone()
	SymmetricKeyframeSequence(KeyframeSequenceClone,MIRROR_GAP)
	KeyframeSequenceClone.Name = keyframeSequenceOrig.Name .. "_Symmetric2"
	KeyframeSequenceClone.Parent = Properties.Directory
end

return AnimMirror