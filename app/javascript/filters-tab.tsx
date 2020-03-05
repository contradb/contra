import React, { useState } from "react"
import Cookie from "js-cookie"
import EzCheckboxFilter from "./ez-checkbox-filter"
import Filter from "./filter"

export const FiltersTab = ({ dictionary }: { dictionary: any }) => {
  const d = dictionary
  const [signedIn] = useState(() => Cookie.get("signed_in"))
  const isAdmin = signedIn === "admin"

  return (
    <div>
      <h4>Choreographer:</h4>
      <input
        type="text"
        className="ez-choreographer-filter form-control"
        style={{ maxWidth: "15em" }}
        value={d.choreographer}
        onChange={e => d.setChoreographer(e.target.value)}
        title="the person who wrote the dance - optional"
      />
      <br />
      <h4>Hook:</h4>
      <input
        type="text"
        className="ez-hook-filter form-control"
        style={{ maxWidth: "15em" }}
        value={d.hook}
        onChange={e => d.setHook(e.target.value)}
        title="search for words in reason the dance is interesting - optional"
      />
      <br />
      <br />
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
      <br />
      <br />
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
      <br />
      <br />
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
