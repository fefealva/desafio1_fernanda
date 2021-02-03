function plota_grafico(x, y, coef; num_linha::Integer = 40, ativoj::Integer =1)
    graf = plot(x[1:num_linha], y[1:num_linha, ativoj], size=(2500,1300), width=3)
    plot!(x[1:num_linha], coef[1:num_linha, ativoj], width=3)
end
