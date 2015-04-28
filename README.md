# Realm createOrUpdate example
An example demonstrating Realm and its createOrUpdate functionality

[In Realm Cocoa 0.87.0](https://realm.io/news/realm-cocoa-0.87.0/), they announced the ability to do partial updates via createOrUpdate

createOrUpdateInRealm:withObject: and friends now support partially updating existing objects. Passing a dictionary with keys set for only some of the fields will leave the existing values alone for all other fields if the object exists already (or use the default values if it does not). Naturally the primary key field must always be present, of course.

```objective-c
// Set the email field of the existing User object with primary key `key` to
// `newEmail`, and leave the rest of the properties unchanged
[User createOrUpdateInDefaultRealmWithObject:@{@"key": key, @"email": newEmail}];
```

What I've found in practice however is that **nested partial objects have missing values reset to their default values** when the object that links to that object receives a partial update.

This project serves to demonstrate this issue which still exists as of Realm Cocoa 0.94.1.

Diving into the code, the issue appears to surface itself around the difference between the following calls in 
```objective-c
/*RLMObjectStore.mm:511*/
NSDictionary *dict = RLMValidatedDictionaryForObjectSchema(value, objectSchema, schema, !created);

/*
 * Which dives into:
 */

/*RLMUtil.mm:232*/
outDict[prop.name] = RLMValidatedObjectForProperty(obj, prop, schema);

/*
 * Then attempts validation:
 */

/*RLMUtil.mm:167*/ 
if (!RLMIsObjectValidForProperty(obj, prop)) {

/*
 * Which tries to dynamically type-cast the nested object into a RLMObject
 */

/*RLMUtil.mm:140*/
RLMObjectBase *objBase = RLMDynamicCast<RLMObjectBase>(obj);
/*
 * but it returns nil as it's not a subclass of the generic type RLMObjectBase
 */

/*RLMUtil.hpp:75-81*/
template<typename T>
static inline T *RLMDynamicCast(__unsafe_unretained id obj) {
    if ([obj isKindOfClass:[T class]]) {
        return obj;
    }
    return nil;
}

/*
 * Because the nested object (in my case is an NSDictionary), 
 * fails validation so when control yields back up to 
 * RLMValidatedObjectForProperty, it will cause a new object
 * initialized
 */

/*RLMUtil.mm:172*/
return [[objSchema.objectClass alloc] initWithObject:obj schema:schema];

/*
 * Keep going:
 */

/*RLMBaseObject.mm:73 -- note we're about to go into a cycle, however at 
  this point the function call has lost the "!created" property as above */
NSDictionary *dict = RLMValidatedDictionaryForObjectSchema(value, _objectSchema, schema);

```            

By this point, for the nested objects -- It's intantiated a new object and filled it out with default values for any missing keys, so control finally yields back to RLMObjectStore.mm it overwrites the existing value:

```objective-c
/*RLMObjectStore.mm:518-519*/
RLMDynamicSet(object, prop, propValue,
              options | RLMCreationOptionsUpdateOrCreate | (prop.isPrimary ? RLMCreationOptionsEnforceUnique : 0));
```                              
This call however is so fundamental that Realm would be acting here exacly as intended so the issue likely somewhere around the point where it attempts to cast the nested object or not forwarding the allowsMissing property down the chain through to RLMValidatedObjectForProperty.

Given that we know that the root object we're updating already exists -- it could be worth doing a lookup downstream to find the object which contains the primaryKey as provided in the nested object and fetch/update that instead of allowing it to fail the cast and create a new object with defaults.
