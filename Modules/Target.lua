--- This requires Argus until someone can write up something
--- to query the boss icons like Argus does, or provide some
--- alternative system for indicating if a monster is a boss
--- or not.
--- uwu

local Target = {

}

function Target.current()
    return Player:GetTarget()
end

return Target