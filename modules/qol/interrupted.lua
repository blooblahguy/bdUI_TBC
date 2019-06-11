local channel = 'SAY'

bdUI:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', function(self, event, ...)
	if select(2,...) ~= 'SPELL_INTERRUPT' then return end
	if select(5,...) ~= UnitName('player') then return end
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15 = ...
	SendChatMessage('Interrupted ' .. GetSpellLink(arg15), channel)
end)