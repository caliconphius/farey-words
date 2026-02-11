@option "default" struct Default end
@option "uppercase" struct UpperCaseSymbol end

@option struct GroupConfig
    element_sep::String
    inv_symbol::Union{Default, UpperCaseSymbol} = UpperCaseSymbol()
    show_powers::Bool
end

function GroupConfig(input::Dict{String,Any})
    config_keys = ["separator", "inverse_symbol", "show_powers"]
    (sep_name, inv_name, pow_name) = config_keys
    element_sep = input[sep_name]

    inv_symbol = @match input[inv_name] begin
        "uppercase" => UpperCaseSymbol()
        _ => Default()
    end

    show_powers = input[pow_name]

    GroupConfig(element_sep, inv_symbol, show_powers)
end

function make_config(s::AbstractString="settings.toml")::GroupConfig
    toml_values = TOML.parsefile(s)
    display_pars = toml_values["display"]
    GroupConfig(display_pars)
end



inv_symbol(x::Symbol, ::UpperCaseSymbol)::Symbol = begin
    x_str = string(x)
    xi::String = match(r"([a-z])(\d*)",x_str)===nothing ? x_str*"_" : uppercase(x_str)
               
    Symbol(xi)
end

inv_symbol(x::Symbol, ::Default)::Symbol = begin
    (x       |> 
    string  |> 
    s->s*"_")|>
    Symbol
end


