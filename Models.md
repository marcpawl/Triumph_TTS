# Adding models for a base

Look in scripts/data if there is a file data_models_*
for the army you want to add models for.

If not create a new file, and add it to data_models.ttslua

Go in Meshwesh and find the army.

Copy down the army id, the GUID in URL in Meshwesh.
e.g. https://meshwesh.wgcwar.com/armyList/5fb1b9e2e1af060017709932/explore
the army id is 5fb1b9e2e1af060017709932.

In the data models file indicate that models are available for the 
army.  
e.g. army['5fb1b9e0e1af06001770979e'].data.has_models = true

You will be getting base ID that from 
fake_meshwesh/army_data/ARMY_ID_base_definitions.ttslua.
Find the definition for the base that you want to add models for.
Copy down the variable that holds the ID, e.g. g_str_68c995d857916300158891a4

g_models holds the definitions for all models, and are defined in the various
data_models_* files, which add to the global variable.


If there is an existing base that has the contents that you want, you can reuse 
it by:
  - Refactor by giving the existing base a named variable, e.g. 
    indian_spearmen_200bc, and use the variable in the g_models entry.
  - Add a new entry in your data_models file.

## Model Defintion

There are three different ways to define a model.
For generals use the figures in order to have the
nice general and his guards look.  Otherwise
use the random method, as it provides the most
variety on the tabletop, even if for now there
is only one troop it provides an easy location
to add more troops.

### Object containing all the figures on the base
 model_data = 'troop_indian_pk'

### Figures in order on the base

n_models: Number of models that should be rendered

fixed_models: The troops to use.  Must have the same
number of models as indicated in n_models.

loose = true: When set the troops will not be aligned,
  which is used to indicate that the base is
  open ordered.

Example:
```
    -- Spearmen with long spears - Light Spear General
    g_models[g_str_68c995d957916300158896ba_general] = {
      {
        n_models = 3,
        fixed_models = {
          [1] = 'troop_indian_pk',
          [2] = 'troop_indian_leader',
          [3] = 'troop_indian_pk'
        }
      }
    }
```


### Troops chosen at random

n_models: Number of models that should be rendered

loose = true: When set the troops will not be aligned,
  which is used to indicate that the base is
  open ordered.

random_models: Troops to choose from.  If there are
less troops than n_models, then a troop may be repeated.


    -- Bowmen - Bow Levy
    g_models[g_str_68c995d957916300158896bf] = {
      {
        loose = true,
        n_models = 3,
        random_models = {
          'troop_indian_ps',
          'troop_indian_bow',
        }
       }
    }

