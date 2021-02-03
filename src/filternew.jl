#ideia:
# dado de entrada da tabela: somente as colunas com os ativos a serem analisados

function estima_coeficientes(tabela::DataFrame; num_linha::Integer = 40, M::Integer = 10^5, K::Integer = 5, ativoj::Integer = 1) 
    lin, col= size(tabela[1:num_linha, :]) 

    x = Vector{Int64}(undef, lin) #criando um vetor x que irá representar a escala de tempo
    y = Matrix(tabela)#vetor do valor da carga
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

    coef= JuMP.value.(τ)

    return x, y, coef

end

