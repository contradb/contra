import React, { useState } from "react"
import Cookie from "js-cookie"
import EzTextFilter from "./ez-text-filter"
import EzCheckboxFilter from "./ez-checkbox-filter"

export const FiltersTab = ({
  dictionary,
}: {
  dictionary: any
}): JSX.Element => {
  const d = dictionary
  const [signedIn] = useState(() => Cookie.get("signed_in"))
  const isAdmin = signedIn === "admin"

  return (
    <div className="filters-tab">
      <EzTextFilter
        name="Title"
        inputClass="ez-title-filter"
        value={d.title}
        setValue={d.setTitle}
        toolTip="the name of the dance - optional"
      />
      <div className="ez-filter-spacer" />
      <EzTextFilter
        name="Choreographer"
        inputClass="ez-choreographer-filter"
        value={d.choreographer}
        setValue={d.setChoreographer}
        toolTip="the name of the dance - optional"
      />
      <div className="ez-filter-spacer" />
      <EzTextFilter
        name="User"
        inputClass="ez-user-filter"
        value={d.user}
        setValue={d.setUser}
        toolTip="the name of the dance - optional"
      />
      <div className="ez-filter-spacer" />
      <EzTextFilter
        name="Hook"
        inputClass="ez-hook-filter"
        value={d.hook}
        setValue={d.setHook}
        toolTip="the name of the dance - optional"
      />
      <div className="ez-filter-spacer" />
      <h4>Verified:</h4>
      <EzCheckboxFilter
        checked={d.verifiedChecked}
        setChecked={d.setVerifiedChecked}
        name="verified"
        title="search among dances that have been called"
      />
      <EzCheckboxFilter
        checked={d.notVerifiedChecked}
        setChecked={d.setNotVerifiedChecked}
        name="not verified"
        title="search among dances that have not been called "
      />
      <EzCheckboxFilter
        checked={d.verifiedCheckedByMe}
        setChecked={d.setVerifiedCheckedByMe}
        disabledReason={signedIn ? null : "must be logged in"}
        name="verified by me"
        title="search among dances that you have called"
      />
      <EzCheckboxFilter
        checked={d.notVerifiedCheckedByMe}
        setChecked={d.setNotVerifiedCheckedByMe}
        disabledReason={signedIn ? null : "must be logged in"}
        name="not verified by me"
        title="search among dances you have not called"
      />
      <div className="ez-filter-spacer" />
      <h4>Shared:</h4>
      <EzCheckboxFilter
        checked={d.publishAll}
        setChecked={d.setPublishAll}
        name="shared"
        title="search among dances shared to all"
      />
      <EzCheckboxFilter
        checked={d.publishSketchbook}
        setChecked={d.setPublishSketchbook}
        name="sketchbooks"
        title="search among dances shared to sketchbooks - the person entering them does not think they should be called"
      />
      {isAdmin && (
        <EzCheckboxFilter
          checked={d.publishOff}
          setChecked={d.setPublishOff}
          name="private"
          title="search among dances that have sharing off"
        />
      )}
      <EzCheckboxFilter
        checked={d.enteredByMe}
        setChecked={d.setEnteredByMe}
        disabledReason={signedIn ? null : "must be logged in"}
        name="entered by me"
        title="search among dances you have entered"
      />
      <div className="ez-filter-spacer" />
      <h4>Formation:</h4>
      <EzCheckboxFilter
        checked={d.improper}
        setChecked={d.setImproper}
        name="improper"
        title="search among duple improper contras"
      />
      <EzCheckboxFilter
        checked={d.becket}
        setChecked={d.setBecket}
        name="becket"
        title="search among Becket contras"
      />
      <EzCheckboxFilter
        checked={d.proper}
        setChecked={d.setProper}
        name="proper"
        title="search among duple proper contras"
      />
      <EzCheckboxFilter
        checked={d.otherFormation}
        setChecked={d.setOtherFormation}
        name="everything else"
        title="search among all the other formations"
      />
    </div>
  )
}
export default FiltersTab
