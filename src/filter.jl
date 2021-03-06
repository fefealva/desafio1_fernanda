function estima_e_plota_os_ativos_e_a_reta_otima(tabela::DataFrame, M::Integer, K::Integer, ativoj::Integer; num_linha_ate_onde_vai_rodar::Integer = 40) 
    carga = tabela[1:num_linha_ate_onde_vai_rodar, 4:end]
    lin, col= size(carga)

    x = Vector{Int64}(undef, lin) #criando um vetor x que irá representar a escala de tempo
    y = Matrix(carga)#vetor do valor da carga
    for i=1:lin
        x[i] = i  #preenchendo o vetor x com valores da escala de tempo
    end
    model = Model(with_optimizer(Gurobi.Optimizer))

    @variable(model, τ[1:lin, 1:col])
    @variable(model, I[1:lin], Bin)

    @constraint(model,[t=2:lin-1, j=1:col], -I[t]*M <=(τ[t+1, j]-2*τ[t, j]+ τ[t-1, j]))
    @constraint(model,[t=2:lin-1, j=1:col],(τ[t+1, j]-2*τ[t,j]+τ[t-1, j])<=I[t]*M)
    @constraint(model, sum(I[t] for t=1:lin)<=K)

    @objective(model, Min, sum(sum( (y[t,j]-τ[t,j])^2 for t = 1:lin) for j=1:col))

    optimize!(model)
    termination_status(model)
    objective_value(model)

    val_reta_otima = JuMP.value.(τ)

    graf = plot(x[1:num_linha_ate_onde_vai_rodar], y[1:num_linha_ate_onde_vai_rodar, ativoj], size=(2500,1300), width=3)
    plot!(x[1:num_linha_ate_onde_vai_rodar], val_reta_otima[1:num_linha_ate_onde_vai_rodar, ativoj], width=3)
    return val_reta_otima, graf

end

#chamar a função de um nome com até 2 palavras
#fazer um modulo mais generico  --> entrada poderia ser o carga/ dependent-Matrix
#passar a tabela com o numero de linhas exatos seria mais inteligente.
#variaveis q o usuario precisa passar e variaveis que ele nao precisa passar necessariamente



# function soma(x; y=1, z=2)
#     summ = x+y+z
#     return summ
# end

# soma(10, y=3)