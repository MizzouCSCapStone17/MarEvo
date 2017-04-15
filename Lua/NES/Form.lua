function incX(amount)
    xval = xval + amount
    return xval
end

function incY(amount)
    yval = yval + amount
    return yval
end

function onExit()
	forms.destroy(form)
end

function createForm(x, y, boxX, boxY)
    yval = 5
    xval = 5
    
    form = forms.newform(boxX, boxY, "MarEvo Settings")
    
    showNeuralNet = forms.checkbox(form, "Show NN", xval, yval)
    showMutationRates = forms.checkbox(form, "Show Mutate Rates", incX(x), yval)
    yval = incY(y) 
    xval = 0
    
     --saves ethe neural network and pool
    saveButton = forms.button(form, "Save", savePool, xval, yval)
    --loads the neural network and pool
    loadButton = forms.button(form, "Load", loadPool, incX(x), yval) --Load the Network
    restartButton = forms.button(form, "Restart", initializePool, incX(x), yval) --Restart the experiment
    yval=incY(y) xval=0
    --File Save
    saveLoadLabel = forms.label(form, "Save/Load:", xval, yval)
    saveLoadFile = forms.textbox(form, ".pool", 110, 25, nil, incX(x), yval)
end