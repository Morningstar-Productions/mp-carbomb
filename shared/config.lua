return {
    Notify = function(message, type, duration)
        lib.notify({
            description = message,
            type = type,
            duration = duration,
        })
    end,

    detonateType = 2,
    timeTakenToArm = 4,
    timeUntilDetonation = 10,
    triggerKey = 47,
    maxSpeed = 50,
    speedType = 'mph'
}